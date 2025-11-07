import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    // Store in shared folder - modify path as needed for your organization
    String path = join('C:\\SharedData\\RewardsApp', 'rewards_db.db');
    
    // Create directory if it doesn't exist
    Directory(dirname(path)).createSync(recursive: true);
    
    return await openDatabase(
      path,
      version: 4, // ✅ UPDATED VERSION to 4
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> cleanupOrphanedRewards() async {
    final db = await database;
    
    // Delete rewards that reference non-existent employees
    await db.execute('''
      DELETE FROM rewards 
      WHERE employee_id NOT IN (SELECT id FROM employees)
    ''');
  }

  // ✅ Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add evaluation columns to existing rewards table
      await db.execute('ALTER TABLE rewards ADD COLUMN evaluation_score INTEGER');
      await db.execute('ALTER TABLE rewards ADD COLUMN savings_potential TEXT');
      await db.execute('ALTER TABLE rewards ADD COLUMN intangible_benefit TEXT');
      await db.execute('ALTER TABLE rewards ADD COLUMN feasible_to_implement TEXT');
      await db.execute('ALTER TABLE rewards ADD COLUMN investment_required TEXT');
      await db.execute('ALTER TABLE rewards ADD COLUMN creativity TEXT');
      await db.execute('ALTER TABLE rewards ADD COLUMN type_of_implementation TEXT');
      await db.execute('ALTER TABLE rewards ADD COLUMN extra_miles TEXT');
    }
    
    if (oldVersion < 3) {
      // Create award_rules_content table
      await db.execute('''
        CREATE TABLE award_rules_content (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          content_text TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      // Insert default common rules
      await db.insert('award_rules_content', {
        'category': 'common',
        'content_text': '''Award Rules & Guidelines:

• Awards are based on evaluation scores calculated from 6 key criteria
• Maximum of 2 awards per employee per calendar year
• Same category cannot be awarded twice to the same employee in a year''',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    
    // ✅ NEW: Add min_score and max_score columns to reward_categories
    if (oldVersion < 4) {
      // Check if columns already exist (in case of manual fixes)
      var tableInfo = await db.rawQuery('PRAGMA table_info(reward_categories)');
      var columnNames = tableInfo.map((col) => col['name'] as String).toList();
      
      if (!columnNames.contains('min_score')) {
        await db.execute('ALTER TABLE reward_categories ADD COLUMN min_score INTEGER DEFAULT 0');
      }
      
      if (!columnNames.contains('max_score')) {
        await db.execute('ALTER TABLE reward_categories ADD COLUMN max_score INTEGER DEFAULT 100');
      }
      
      // Update existing categories with appropriate score ranges
      await db.execute('''
        UPDATE reward_categories 
        SET min_score = 91, max_score = 100 
        WHERE LOWER(name) = 'platinum'
      ''');
      
      await db.execute('''
        UPDATE reward_categories 
        SET min_score = 81, max_score = 90 
        WHERE LOWER(name) = 'gold'
      ''');
      
      await db.execute('''
        UPDATE reward_categories 
        SET min_score = 71, max_score = 80 
        WHERE LOWER(name) = 'silver'
      ''');
      
      await db.execute('''
        UPDATE reward_categories 
        SET min_score = 61, max_score = 70 
        WHERE LOWER(name) LIKE '%certificate%voucher%' OR LOWER(name) LIKE '%voucher%'
      ''');
      
      await db.execute('''
        UPDATE reward_categories 
        SET min_score = 0, max_score = 60 
        WHERE LOWER(name) = 'certificate' AND LOWER(name) NOT LIKE '%voucher%'
      ''');
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        department TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Employees table
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        department TEXT NOT NULL,
        position TEXT,
        email TEXT,
        manager_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (manager_id) REFERENCES users (id)
      )
    ''');
    
    // ✅ FIXED: Reward categories table with correct column names
    await db.execute('''
      CREATE TABLE reward_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        approval_level INTEGER NOT NULL,
        monetary_value REAL,
        min_score INTEGER DEFAULT 0,
        max_score INTEGER DEFAULT 100,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Rewards table with evaluation fields
    await db.execute('''
      CREATE TABLE rewards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        nominated_by INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        current_approval_level INTEGER DEFAULT 1,
        level1_approver INTEGER,
        level2_approver INTEGER,
        level3_approver INTEGER,
        level1_status TEXT DEFAULT 'pending',
        level2_status TEXT DEFAULT 'pending',
        level3_status TEXT DEFAULT 'pending',
        level1_comment TEXT,
        level2_comment TEXT,
        level3_comment TEXT,
        submitted_at TEXT DEFAULT CURRENT_TIMESTAMP,
        approved_at TEXT,
        evaluation_score INTEGER,
        savings_potential TEXT,
        intangible_benefit TEXT,
        feasible_to_implement TEXT,
        investment_required TEXT,
        creativity TEXT,
        type_of_implementation TEXT,
        extra_miles TEXT,
        FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES reward_categories (id),
        FOREIGN KEY (nominated_by) REFERENCES users (id)
      )
    ''');
    
    // Award rules content table
    await db.execute('''
      CREATE TABLE award_rules_content (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        content_text TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Insert default data
    await _insertDefaultData(db);
  }
  
  Future<void> _insertDefaultData(Database db) async {
    // Default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123', // In production, hash this
      'full_name': 'System Administrator',
      'email': 'admin@company.com',
      'role': 'ADMIN',
      'department': 'IT'
    });
    
    // ✅ Reward categories with score ranges
    await db.insert('reward_categories', {
      'name': 'Platinum',
      'description': 'Score 91-100: Exceptional achievement with maximum impact',
      'approval_level': 3,
      'monetary_value': 100000.0,
      'min_score': 91,
      'max_score': 100
    });
    
    await db.insert('reward_categories', {
      'name': 'Gold',
      'description': 'Score 81-90: Outstanding contribution and excellence',
      'approval_level': 3,
      'monetary_value': 75000.0,
      'min_score': 81,
      'max_score': 90
    });
    
    await db.insert('reward_categories', {
      'name': 'Silver',
      'description': 'Score 71-80: Significant achievement and dedication',
      'approval_level': 2,
      'monetary_value': 50000.0,
      'min_score': 71,
      'max_score': 80
    });
    
    await db.insert('reward_categories', {
      'name': 'Certificate + Voucher',
      'description': 'Score 61-70: Commendable performance and effort',
      'approval_level': 2,
      'monetary_value': 25000.0,
      'min_score': 61,
      'max_score': 70
    });
    
    await db.insert('reward_categories', {
      'name': 'Certificate',
      'description': 'Score below 60: Recognition for good contribution',
      'approval_level': 1,
      'monetary_value': 10000.0,
      'min_score': 0,
      'max_score': 60
    });
    
    // Insert default common award rules
    await db.insert('award_rules_content', {
      'category': 'common',
      'content_text': '''Award Rules & Guidelines:

• Employees must meet all eligibility criteria before nomination
• All achievements must be documented and verifiable
• Awards are based on evaluation scores calculated from 6 key criteria
• Maximum of 2 awards per employee per calendar year
• Same category cannot be awarded twice to the same employee in a year
• Cost savings and benefits must be substantiated with evidence
• Innovation must be implemented and show measurable results
• Awards are non-transferable and subject to approval
• Management reserves the right to review and modify awards
• All decisions by the approval committee are final''',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}