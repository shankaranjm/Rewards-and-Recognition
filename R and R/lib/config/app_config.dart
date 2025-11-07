class AppConfig {
  // Database configuration
  static const String DATABASE_NAME = 'rewards_db.db';
  
  // Update this path to your organization's shared folder
  static const String SHARED_FOLDER_PATH = r'C:\SharedData\RewardsApp';
  // For network drive, use: r'\\ServerName\SharedFolder\RewardsApp'
  
  // Application settings
  static const String APP_VERSION = '1.0.0';
  static const String APP_NAME = 'Employee Rewards & Recognition';
  
  // Business rules
  static const int MAX_REWARDS_PER_EMPLOYEE_PER_YEAR = 2;
  static const int MIN_REASON_LENGTH = 20;
  
  // Default user roles
  static const List<String> USER_ROLES = [
    'admin',
    'manager', 
    'approver_level1',
    'approver_level2', 
    'approver_level3'
  ];
  
  // Default reward categories with approval levels (INR values)
  static const Map<String, Map<String, dynamic>> DEFAULT_CATEGORIES = {
    'Team Player Award': {
      'description': 'Exceptional teamwork and collaboration',
      'approval_level': 1,
      'monetary_value': 10000.0  // ₹10,000
    },
    'Employee of the Month': {
      'description': 'Outstanding performance recognition',
      'approval_level': 2,
      'monetary_value': 25000.0  // ₹25,000
    },
    'Innovation Award': {
      'description': 'Innovative ideas and implementations',
      'approval_level': 3,
      'monetary_value': 50000.0  // ₹50,000
    },
    'Safety Excellence Award': {
      'description': 'Outstanding commitment to workplace safety',
      'approval_level': 2,
      'monetary_value': 15000.0  // ₹15,000
    },
    'Quality Champion Award': {
      'description': 'Exceptional quality improvements and initiatives',
      'approval_level': 2,
      'monetary_value': 20000.0  // ₹20,000
    },
  };
  
  // Currency settings
  static const String CURRENCY_SYMBOL = '₹';
  static const String CURRENCY_CODE = 'INR';
  
  // Helper method to format currency
  static String formatCurrency(double amount) {
    if (amount >= 100000) {
      return '$CURRENCY_SYMBOL${(amount / 100000).toStringAsFixed(1)}L';  // Lakhs
    } else if (amount >= 1000) {
      return '$CURRENCY_SYMBOL${(amount / 1000).toStringAsFixed(1)}K';     // Thousands
    } else {
      return '$CURRENCY_SYMBOL${amount.toStringAsFixed(0)}';
    }
  }
  
  // Department list (customize for your organization)
  static const List<String> DEPARTMENTS = [
    'Production',
    'Quality Control',
    'Maintenance',
    'Logistics',
    'Engineering',
    'Safety',
    'Human Resources',
    'IT',
    'Finance',
    'Management'
  ];
  
  // Approval workflow settings
  static const Map<int, String> APPROVAL_LEVEL_NAMES = {
    1: 'Supervisor Approval',
    2: 'Manager Approval',
    3: 'Director Approval'
  };
  
  // UI settings
  static const int ITEMS_PER_PAGE = 20;
  static const int MAX_COMMENT_LENGTH = 500;
  
  // File paths
  static String getDatabasePath() {
    return '$SHARED_FOLDER_PATH\\$DATABASE_NAME';
  }
  
  // Helper method to get current year
  static int getCurrentYear() {
    return DateTime.now().year;
  }
  
  // Helper method to get year start and end dates
  static Map<String, String> getCurrentYearRange() {
    int currentYear = getCurrentYear();
    return {
      'start': '$currentYear-01-01T00:00:00.000Z',
      'end': '$currentYear-12-31T23:59:59.999Z',
    };
  }
  

  
  // Validation rules
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidEmployeeId(String employeeId) {
    return employeeId.isNotEmpty && employeeId.length >= 3;
  }
  
  static bool isValidReason(String reason) {
    return reason.trim().length >= MIN_REASON_LENGTH;
  }
}