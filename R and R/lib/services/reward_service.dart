import 'package:rewards_recognition_app/database/databasehelper.dart';

import '../config/app_config.dart';

class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();
  
  /// Check how many rewards an employee has received in the current calendar year
  Future<int> getEmployeeRewardCountForYear(int employeeId, {int? year}) async {
    final db = await DatabaseHelper().database;
    year ??= DateTime.now().year;
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM rewards 
      WHERE employee_id = ? 
      AND status = 'approved' 
      AND strftime('%Y', submitted_at) = ?
    ''', [employeeId, year.toString()]);
    
    return result.first['count'] as int;
  }
  
  /// Check if employee can receive more rewards this year
  Future<bool> canEmployeeReceiveReward(int employeeId, {int? year}) async {
    int count = await getEmployeeRewardCountForYear(employeeId, year: year);
    return count < AppConfig.MAX_REWARDS_PER_EMPLOYEE_PER_YEAR;
  }
  
  /// Get remaining rewards for employee this year
  Future<int> getRemainingRewardsForEmployee(int employeeId, {int? year}) async {
    int count = await getEmployeeRewardCountForYear(employeeId, year: year);
    return AppConfig.MAX_REWARDS_PER_EMPLOYEE_PER_YEAR - count;
  }
  
  /// Get all employees with their current year reward counts
  Future<List<Map<String, dynamic>>> getEmployeesWithRewardCounts({int? year}) async {
    final db = await DatabaseHelper().database;
    year ??= DateTime.now().year;
    
    final result = await db.rawQuery('''
      SELECT e.*, 
             COUNT(CASE WHEN r.status = 'approved' 
                        AND strftime('%Y', r.submitted_at) = ? 
                   THEN 1 END) as current_year_rewards,
             COUNT(CASE WHEN r.status = 'approved' 
                   THEN 1 END) as total_rewards
      FROM employees e
      LEFT JOIN rewards r ON e.id = r.employee_id
      GROUP BY e.id, e.employee_id, e.full_name, e.department, e.position, e.email, e.manager_id
      ORDER BY e.full_name
    ''', [year.toString()]);
    
    return result;
  }
  
  /// Get reward statistics for dashboard
  Future<Map<String, dynamic>> getRewardStatistics({int? year}) async {
    final db = await DatabaseHelper().database;
    year ??= DateTime.now().year;
    
    final totalEmployees = await db.rawQuery('SELECT COUNT(*) as count FROM employees');
    final totalRewards = await db.rawQuery('SELECT COUNT(*) as count FROM rewards');
    final currentYearRewards = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rewards WHERE strftime(\'%Y\', submitted_at) = ?', 
      [year.toString()]
    );
    final pendingApprovals = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rewards WHERE status = ? AND strftime(\'%Y\', submitted_at) = ?', 
      ['pending', year.toString()]
    );
    final currentYearApproved = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rewards WHERE status = ? AND strftime(\'%Y\', submitted_at) = ?', 
      ['approved', year.toString()]
    );
    
    // Employees at limit
    final employeesAtLimit = await db.rawQuery('''
      SELECT COUNT(DISTINCT employee_id) as count 
      FROM rewards 
      WHERE status = 'approved' 
      AND strftime('%Y', submitted_at) = ?
      GROUP BY employee_id 
      HAVING COUNT(*) >= 2
    ''', [year.toString()]);
    
    return {
      'totalEmployees': totalEmployees.first['count'] as int,
      'totalRewards': totalRewards.first['count'] as int,
      'currentYearRewards': currentYearRewards.first['count'] as int,
      'pendingApprovals': pendingApprovals.first['count'] as int,
      'currentYearApproved': currentYearApproved.first['count'] as int,
      'employeesAtLimit': employeesAtLimit.isEmpty ? 0 : employeesAtLimit.length,
      'currentYear': year,
    };
  }
  
  /// Validate reward submission
  Future<Map<String, dynamic>> validateRewardSubmission(int employeeId, int categoryId) async {
    final canReceive = await canEmployeeReceiveReward(employeeId);
    final remaining = await getRemainingRewardsForEmployee(employeeId);
    final currentCount = await getEmployeeRewardCountForYear(employeeId);
    final currentYear = DateTime.now().year;
    
    return {
      'isValid': canReceive,
      'currentCount': currentCount,
      'remaining': remaining,
      'year': currentYear,
      'message': canReceive 
        ? 'Employee can receive $remaining more reward(s) in $currentYear'
        : 'Employee has reached maximum limit (2) for calendar year $currentYear'
    };
  }
  
  /// Get employees eligible for rewards (under 2 for current year)
  Future<List<Map<String, dynamic>>> getEligibleEmployees({int? year}) async {
    final db = await DatabaseHelper().database;
    year ??= DateTime.now().year;
    
    final result = await db.rawQuery('''
      SELECT e.*, 
             COUNT(CASE WHEN r.status = 'approved' 
                        AND strftime('%Y', r.submitted_at) = ? 
                   THEN 1 END) as current_year_rewards
      FROM employees e
      LEFT JOIN rewards r ON e.id = r.employee_id
      GROUP BY e.id, e.employee_id, e.full_name, e.department, e.position, e.email, e.manager_id
      HAVING current_year_rewards < 2
      ORDER BY e.full_name
    ''', [year.toString()]);
    
    return result;
  }
  
  /// Get year-over-year comparison
  Future<Map<String, dynamic>> getYearOverYearComparison() async {
    final db = await DatabaseHelper().database;
    final currentYear = DateTime.now().year;
    final lastYear = currentYear - 1;
    
    final currentYearStats = await db.rawQuery('''
      SELECT COUNT(*) as total,
             COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved
      FROM rewards 
      WHERE strftime('%Y', submitted_at) = ?
    ''', [currentYear.toString()]);
    
    final lastYearStats = await db.rawQuery('''
      SELECT COUNT(*) as total,
             COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved
      FROM rewards 
      WHERE strftime('%Y', submitted_at) = ?
    ''', [lastYear.toString()]);
    
    return {
      'currentYear': {
        'year': currentYear,
        'total': currentYearStats.first['total'] as int,
        'approved': currentYearStats.first['approved'] as int,
      },
      'lastYear': {
        'year': lastYear,
        'total': lastYearStats.first['total'] as int,
        'approved': lastYearStats.first['approved'] as int,
      },
    };
  }
}