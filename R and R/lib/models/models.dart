class User {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String role;
  final String? department;
  
  User({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.role,
    this.department,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'full_name': fullName,
      'email': email,
      'role': role,
      'department': department,
    };
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'],
      password: map['password'],
      fullName: map['full_name'],
      email: map['email'],
      role: map['role'],
      department: map['department'],
    );
  }
}

class Employee {
  final int? id;
  final String employeeId;
  final String fullName;
  final String department;
  final String? position;
  final String? email;
  final int? managerId;
  
  Employee({
    this.id,
    required this.employeeId,
    required this.fullName,
    required this.department,
    this.position,
    this.email,
    this.managerId,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'full_name': fullName,
      'department': department,
      'position': position,
      'email': email,
      'manager_id': managerId,
    };
  }
  
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id']as int?,
      employeeId: map['employee_id'],
      fullName: map['full_name'],
      department: map['department'],
      position: map['position'],
      email: map['email'],
      managerId: map['manager_id'],
    );
  }
}

class RewardCategory {
  final int? id;
  final String name;
  final String? description;
  final int approvalLevel;
  final double? monetaryValue;
  final int? minScore;  // ✅ NEW
  final int? maxScore; 
  
  RewardCategory({
    this.id,
    required this.name,
    this.description,
    required this.approvalLevel,
    this.monetaryValue,
    this.minScore,  // ✅ NEW
    this.maxScore,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'approval_level': approvalLevel,
      'monetary_value': monetaryValue,
      'min_score': minScore,  // ✅ NEW
      'max_score': maxScore,
      
    };
  }
  
  factory RewardCategory.fromMap(Map<String, dynamic> map) {
    return RewardCategory(
      id: map['id']as int?,
      name: map['name'],
      description: map['description'],
      approvalLevel: map['approval_level'],
      monetaryValue: map['monetary_value'],
      minScore: map['min_score'],  
      maxScore: map['max_score'],
    );
  }
}

class Reward {
  final int? id;
  final int employeeId;
  final int categoryId;
  final int nominatedBy;
  final String reason;
  final String status;
  final int currentApprovalLevel;
  final int? level1Approver;
  final int? level2Approver;
  final int? level3Approver;
  final String level1Status;
  final String level2Status;
  final String level3Status;
  final String? level1Comment;
  final String? level2Comment;
  final String? level3Comment;
  final String? submittedAt;
  final String? approvedAt;
  
  Reward({
    this.id,
    required this.employeeId,
    required this.categoryId,
    required this.nominatedBy,
    required this.reason,
    this.status = 'pending',
    this.currentApprovalLevel = 1,
    this.level1Approver,
    this.level2Approver,
    this.level3Approver,
    this.level1Status = 'pending',
    this.level2Status = 'pending',
    this.level3Status = 'pending',
    this.level1Comment,
    this.level2Comment,
    this.level3Comment,
    this.submittedAt,
    this.approvedAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id ,
      'employee_id': employeeId,
      'category_id': categoryId,
      'nominated_by': nominatedBy,
      'reason': reason,
      'status': status,
      'current_approval_level': currentApprovalLevel,
      'level1_approver': level1Approver,
      'level2_approver': level2Approver,
      'level3_approver': level3Approver,
      'level1_status': level1Status,
      'level2_status': level2Status,
      'level3_status': level3Status,
      'level1_comment': level1Comment,
      'level2_comment': level2Comment,
      'level3_comment': level3Comment,
      'submitted_at': submittedAt,
      'approved_at': approvedAt,
    };
  }
  
  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id']as int?,
      employeeId: map['employee_id'],
      categoryId: map['category_id'],
      nominatedBy: map['nominated_by'],
      reason: map['reason'],
      status: map['status'] ?? 'pending',
      currentApprovalLevel: map['current_approval_level'] ?? 1,
      level1Approver: map['level1_approver'],
      level2Approver: map['level2_approver'],
      level3Approver: map['level3_approver'],
      level1Status: map['level1_status'] ?? 'pending',
      level2Status: map['level2_status'] ?? 'pending',
      level3Status: map['level3_status'] ?? 'pending',
      level1Comment: map['level1_comment'],
      level2Comment: map['level2_comment'],
      level3Comment: map['level3_comment'],
      submittedAt: map['submitted_at'],
      approvedAt: map['approved_at'],
    );
  }
}