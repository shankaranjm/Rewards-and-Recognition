// // // import 'package:flutter/material.dart';
// // // import 'package:rewards_recognition_app/database/databasehelper.dart';
// // // import '../../models/models.dart';

// // // class SubmitRewardPage extends StatefulWidget {
// // //   final User user;

// // //   // ❌ REMOVED THE UNUSED 'int i' FROM THE CONSTRUCTOR
// // //   SubmitRewardPage({required this.user});

// // //   @override
// // //   _SubmitRewardPageState createState() => _SubmitRewardPageState();
// // // }

// // // class _SubmitRewardPageState extends State<SubmitRewardPage> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _reasonController = TextEditingController();

// // //   Employee? _selectedEmployee;
// // //   RewardCategory? _selectedCategory;
// // //   List<Employee> _employees = [];
// // //   List<RewardCategory> _categories = [];
// // //   bool _isLoading = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadData();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _reasonController.dispose();
// // //     super.dispose();
// // //   }

// // //   Future<void> _loadData() async {
// // //     final db = await DatabaseHelper().database;

// // //     final employeeData = await db.query('employees');
// // //     _employees = employeeData.map((e) => Employee.fromMap(e)).toList();

// // //     final categoryData = await db.query('reward_categories');
// // //     _categories = categoryData.map((c) => RewardCategory.fromMap(c)).toList();

// // //     setState(() {});
// // //   }

// // //   // ✅ New method to explicitly reset the form fields
// // //   void _resetForm() {
// // //     _reasonController.clear();
// // //     setState(() {
// // //       _selectedEmployee = null;
// // //       _selectedCategory = null;
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Padding(
// // //       padding: EdgeInsets.all(20),
// // //       child: Card(
// // //         child: Padding(
// // //           padding: EdgeInsets.all(20),
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(
// // //                 'Submit New Reward',
// // //                 style: Theme.of(context).textTheme.headlineLarge,
// // //               ),
// // //               SizedBox(height: 20),
// // //               Expanded(
// // //                 child: Form(
// // //                   key: _formKey,
// // //                   child: ListView(
// // //                     children: [
// // //                       // Employee Selection
// // //                       DropdownButtonFormField<Employee>(
// // //                         key: ValueKey(_selectedEmployee), // ✅ Added a key to force rebuild
// // //                         decoration: InputDecoration(
// // //                           labelText: 'Select Employee',
// // //                           border: OutlineInputBorder(),
// // //                         ),
// // //                         value: _selectedEmployee,
// // //                         items: _employees.map((employee) {
// // //                           return DropdownMenuItem(
// // //                             value: employee,
// // //                             child: Text(
// // //                                 '${employee.fullName} (${employee.employeeId})'),
// // //                           );
// // //                         }).toList(),
// // //                         onChanged: (employee) async {
// // //                           setState(() {
// // //                             _selectedEmployee = employee;
// // //                           });

// // //                           if (employee != null) {
// // //                             final db = await DatabaseHelper().database;
// // //                             int currentYear = DateTime.now().year;
// // //                             final rewardCount = await db.rawQuery('''
// // //                               SELECT COUNT(*) as count 
// // //                               FROM rewards 
// // //                               WHERE employee_id = ? 
// // //                               AND strftime('%Y', submitted_at) = ?
// // //                             ''', [employee.id, currentYear.toString()]);
// // //                             int count = rewardCount.first['count'] as int;
// // //                             if (count >= 2) {
// // //                               ScaffoldMessenger.of(context).showSnackBar(
// // //                                 SnackBar(
// // //                                   content: Text(
// // //                                       '⚠️ This employee already has 2 rewards in $currentYear'),
// // //                                   backgroundColor: const Color.fromARGB(255, 255, 0, 0),
// // //                                 ),
// // //                               );
// // //                             } else {
// // //                               ScaffoldMessenger.of(context).showSnackBar(
// // //                                 SnackBar(
// // //                                   content: Text(
// // //                                       'ℹ️ Employee currently has $count/2 rewards for $currentYear'),
// // //                                   backgroundColor: const Color.fromARGB(255, 240, 192, 31),
// // //                                 ),
// // //                               );
// // //                             }
// // //                           }
// // //                         },
// // //                         validator: (value) =>
// // //                             value == null ? 'Please select an employee' : null,
// // //                       ),
// // //                       SizedBox(height: 20),

// // //                       // Category Selection
// // //                       DropdownButtonFormField<RewardCategory>(
// // //                         key: ValueKey(_selectedCategory), // ✅ Added a key to force rebuild
// // //                         decoration: const InputDecoration(
// // //                           labelText: 'Reward Category',
// // //                           border: OutlineInputBorder(),
// // //                         ),
// // //                         value: _selectedCategory,
// // //                         items: _categories.map((category) {
// // //                           return DropdownMenuItem(
// // //                             value: category,
// // //                             child: FittedBox(
// // //                               fit: BoxFit.scaleDown,
// // //                               child: Column(
// // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                                 mainAxisSize: MainAxisSize.min,
// // //                                 children: [
// // //                                   Text(category.name,
// // //                                       style: TextStyle(fontSize: 16)),
// // //                                   Text(
// // //                                     'Level ${category.approvalLevel} approval required',
// // //                                     style: TextStyle(
// // //                                         fontSize: 14, color: Colors.grey),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           );
// // //                         }).toList(),
// // //                         onChanged: (category) {
// // //                           setState(() {
// // //                             _selectedCategory = category;
// // //                           });
// // //                         },
// // //                         validator: (value) => value == null
// // //                             ? 'Please select a reward category'
// // //                             : null,
// // //                       ),
// // //                       SizedBox(height: 20),

// // //                       // Reason Field
// // //                       TextFormField(
// // //                         controller: _reasonController,
// // //                         decoration: InputDecoration(
// // //                           labelText: 'Reason for Recognition',
// // //                           hintText:
// // //                               'Describe why this employee deserves this reward...',
// // //                           border: OutlineInputBorder(),
// // //                         ),
// // //                         maxLines: 5,
// // //                         validator: (value) {
// // //                           if (value == null || value.trim().isEmpty) {
// // //                             return 'Please provide a reason';
// // //                           }
// // //                           if (value.trim().length < 20) {
// // //                             return 'Minimum 20 characters required';
// // //                           }
// // //                           return null;
// // //                         },
// // //                       ),
// // //                       SizedBox(height: 20),

// // //                       if (_selectedCategory != null) ...[
// // //                         Card(
// // //   color: Theme.of(context).colorScheme.surfaceVariant, // ✅ Theme-aware background
// // //                           child: Padding(
// // //                             padding: EdgeInsets.all(15),
// // //                             child: Column(
// // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // //                               children: [
// // //                                 Text('Category Details',
// // //                                     style: TextStyle(
// // //                                         fontWeight: FontWeight.bold,
// // //                                         color: Theme.of(context).colorScheme.onSurfaceVariant, // ✅ Theme-aware text
// // // )),
// // //                                 SizedBox(height: 5),
// // //                                 Text(
// // //                                     'Description: ${_selectedCategory!.description ?? 'N/A'}',
// // //                                      style: TextStyle(
// // //             color: Theme.of(context).colorScheme.onSurfaceVariant, // ✅ Theme-aware text
// // //           ),),
// // //                                 Text(
// // //                                     'Approval Level: Level ${_selectedCategory!.approvalLevel}',
// // //                                     style: TextStyle(
// // //             color: Theme.of(context).colorScheme.onSurfaceVariant, // ✅ Theme-aware text
// // //           ),),
// // //                                 if (_selectedCategory!.monetaryValue != null)
// // //                                   Text(
// // //                                       'Value: ₹${_selectedCategory!.monetaryValue!.toStringAsFixed(0)}',
// // //                                       style: TextStyle(
// // //               color: Theme.of(context).colorScheme.onSurfaceVariant, // ✅ Theme-aware text
// // //             ),),
// // //                                 Text(
// // //                                   'Note: Maximum 2 rewards per employee per calendar year',
// // //                                   style: TextStyle(
// // //                                     fontSize: 12,
// // //             color: Theme.of(context).colorScheme.secondary, // ✅ Theme-aware secondary color
// // //                                     fontStyle: FontStyle.italic,
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         SizedBox(height: 20),
// // //                       ],

// // //                       // Submit Button
// // //                       SizedBox(
// // //                         width: double.infinity,
// // //                         child: ElevatedButton(
// // //                           onPressed: _isLoading ? null : _submitReward,
// // //                           style: ElevatedButton.styleFrom(
// // //                             padding: EdgeInsets.symmetric(vertical: 15),
// // //                             backgroundColor: Colors.green,
// // //                             foregroundColor: Colors.white,
// // //                           ),
// // //                           child: _isLoading
// // //                               ? CircularProgressIndicator(color: Colors.white)
// // //                               : Text('Submit Reward'),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _submitReward() async {
// // //     if (_formKey.currentState!.validate()) {
// // //       setState(() => _isLoading = true);

// // //       try {
// // //         final db = await DatabaseHelper().database;
// // //         int currentYear = DateTime.now().year;

// // //         final rewardCount = await db.rawQuery('''
// // //           SELECT COUNT(*) as count 
// // //           FROM rewards 
// // //           WHERE employee_id = ? 
// // //           AND strftime('%Y', submitted_at) = ?
// // //         ''', [_selectedEmployee!.id, currentYear.toString()]);
// // //         int count = rewardCount.first['count'] as int;

// // //         if (count >= 2) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             SnackBar(
// // //               content: Text(
// // //                   '❌ Cannot submit: Employee already has 2 rewards in $currentYear'),
// // //               backgroundColor: Colors.red,
// // //             ),
// // //           );
// // //           setState(() => _isLoading = false);
// // //           return;
// // //         }

// // //         final approverQuery = await db.query(
// // //           'users',
// // //           where: 'department = ? AND role = ?',
// // //           whereArgs: [_selectedEmployee!.department, 'approver_level1'],
// // //         );

// // //         if (approverQuery.isEmpty) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             SnackBar(
// // //               content: Text(
// // //                   '❌ No Level 1 approver found for ${_selectedEmployee!.department} department.'),
// // //               backgroundColor: Colors.red,
// // //             ),
// // //           );
// // //           setState(() => _isLoading = false);
// // //           return;
// // //         }

// // //         final level1ApproverId = approverQuery.first['id'];

// // //         await db.insert('rewards', {
// // //           'employee_id': _selectedEmployee!.id,
// // //           'category_id': _selectedCategory!.id,
// // //           'nominated_by': widget.user.id,
// // //           'reason': _reasonController.text.trim(),
// // //           'submitted_at': DateTime.now().toIso8601String(),
// // //           'level1_approver': level1ApproverId,
// // //           'level1_status': 'pending',
// // //           'status': 'pending',
// // //           'current_approval_level': 1,
// // //         });

// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text('✅ Reward submitted successfully!'),
// // //             backgroundColor: Colors.green,
// // //           ),
// // //         );

// // //         // ✅ Call the new reset method to ensure a clean refresh
// // //         _resetForm();
// // //       } catch (e) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text('❌ Failed to submit reward: $e'),
// // //             backgroundColor: Colors.red,
// // //           ),
// // //         );
// // //       }
// // //       setState(() => _isLoading = false);
// // //     }
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:rewards_recognition_app/database/databasehelper.dart';
// // import '../models/models.dart';


// // class EmployeeManagementPage extends StatefulWidget {
// //   @override
// //   _EmployeeManagementPageState createState() => _EmployeeManagementPageState();
// // }

// // class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
// //   List<Employee> _employees = [];
// //   List<User> _managers = [];
// //   List<Map<String, dynamic>> _employeesWithRewardCount = [];
// //   List<Map<String, dynamic>> _filteredEmployees = [];
// //   bool _isLoading = true;
// //   bool _showSearch = false;
// //   final TextEditingController _searchController = TextEditingController();
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadData();
// //     _searchController.addListener(_filterEmployees);
// //   }
  
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
  
// //   void _filterEmployees() {
// //     String query = _searchController.text.toLowerCase();
    
// //     setState(() {
// //       if (query.isEmpty) {
// //         _filteredEmployees = _employeesWithRewardCount;
// //       } else {
// //         _filteredEmployees = _employeesWithRewardCount.where((employeeData) {
// //           final employee = Employee.fromMap(employeeData);
// //           final employeeId = employee.employeeId.toLowerCase();
// //           final fullName = employee.fullName.toLowerCase();
// //           final department = employee.department.toLowerCase();
          
// //           return employeeId.contains(query) || 
// //                  fullName.contains(query) || 
// //                  department.contains(query);
// //         }).toList();
// //       }
// //     });
// //   }
  
// //   Future<void> _loadData() async {
// //     final db = await DatabaseHelper().database;
// //     int currentYear = DateTime.now().year;
    
// //     // Load employees with current year reward count
// //     final employeeData = await db.rawQuery('''
// //       SELECT e.*, 
// //              COUNT(CASE WHEN r.status = 'approved' 
// //                         AND strftime('%Y', r.submitted_at) = ? 
// //                    THEN 1 END) as current_year_rewards
// //       FROM employees e
// //       LEFT JOIN rewards r ON e.id = r.employee_id
// //       GROUP BY e.id, e.employee_id, e.full_name, e.department, e.position, e.email, e.manager_id
// //       ORDER BY e.full_name
// //     ''', [currentYear.toString()]);
    
// //     _employeesWithRewardCount = employeeData;
// //     _filteredEmployees = employeeData;
// //     _employees = employeeData.map((e) => Employee.fromMap(e)).toList();
    
// //     // Load managers (users with manager or admin role)
// //     final managerData = await db.query(
// //       'users',
// //       where: 'role IN (?, ?)',
// //       whereArgs: ['manager', 'admin'],
// //     );
// //     _managers = managerData.map((u) => User.fromMap(u)).toList();
    
// //     setState(() {
// //       _isLoading = false;
// //     });
// //   }
  
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: EdgeInsets.all(20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Text(
// //                 'Employee Management',
// //                 style: Theme.of(context).textTheme.headlineLarge,
// //               ),
// //               Spacer(),
// //               if (_showSearch) ...[
// //                 Container(
// //                   width: 300,
// //                   child: TextField(
// //                     controller: _searchController,
// //                     autofocus: true,
// //                     decoration: InputDecoration(
// //                       hintText: 'Search by ID, name or department...',
// //                       prefixIcon: Icon(Icons.search),
// //                       suffixIcon: IconButton(
// //                         icon: Icon(Icons.close),
// //                         onPressed: () {
// //                           setState(() {
// //                             _showSearch = false;
// //                             _searchController.clear();
// //                           });
// //                         },
// //                       ),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       filled: true,
// //                       fillColor: Colors.grey[100],
// //                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(width: 10),
// //               ],
// //               if (!_showSearch)
// //                 IconButton(
// //                   onPressed: () {
// //                     setState(() {
// //                       _showSearch = true;
// //                     });
// //                   },
// //                   icon: Icon(Icons.search),
// //                   tooltip: 'Search',
// //                 ),
// //               SizedBox(width: 10),
// //               ElevatedButton.icon(
// //                 onPressed: () => _showEmployeeDialog(),
// //                 icon: Icon(Icons.add),
// //                 label: Text('Add Employee'),
// //               ),
// //               SizedBox(width: 10),
// //                ElevatedButton.icon(
// //                 onPressed: _uploadExcelFile,
// //                 icon: Icon(Icons.upload_file),
// //                 label: Text('Upload Excel'),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 20),
// //           Expanded(
// //             child: _isLoading
// //                 ? Center(child: CircularProgressIndicator())
// //                 : _filteredEmployees.isEmpty
// //                     ? Center(
// //                         child: Text(
// //                           'No employees found',
// //                           style: TextStyle(fontSize: 16, color: Colors.grey),
// //                         ),
// //                       )
// //                     : SingleChildScrollView(
// //                         scrollDirection: Axis.horizontal,
// //                         child: DataTable(
// //                           columns: [
// //                             DataColumn(label: Text('Employee ID')),
// //                             DataColumn(label: Text('Full Name')),
// //                             DataColumn(label: Text('Department')),
// //                             DataColumn(label: Text('Position')),
// //                             DataColumn(label: Text('Email')),
// //                             DataColumn(label: Text('Rewards Count')),
// //                             DataColumn(label: Text('Actions')),
// //                           ],
// //                           rows: _filteredEmployees.map((employeeData) {
// //                             final employee = Employee.fromMap(employeeData);
// //                             int currentYearRewards = employeeData['current_year_rewards'] ?? 0;
// //                             int currentYear = DateTime.now().year;
                            
// //                             return DataRow(
// //                               color: MaterialStateProperty.resolveWith<Color?>(
// //                                 (Set<MaterialState> states) {
// //                                   if (currentYearRewards >= 2) {
// //                                     return Colors.red.shade50;
// //                                   }
// //                                   return null;
// //                                 },
// //                               ),
// //                               cells: [
// //                                 DataCell(Text(employee.employeeId)),
// //                                 DataCell(Text(employee.fullName)),
// //                                 DataCell(Text(employee.department)),
// //                                 DataCell(Text(employee.position ?? '')),
// //                                 DataCell(Text(employee.email ?? '')),
// //                                 DataCell(
// //                                   Row(
// //                                     mainAxisSize: MainAxisSize.min,
// //                                     children: [
// //                                       Text('$currentYearRewards/2 ($currentYear)'),
// //                                       if (currentYearRewards >= 2) ...[
// //                                         SizedBox(width: 5),
// //                                         Icon(Icons.warning, color: Colors.red, size: 16),
// //                                       ],
// //                                     ],
// //                                   ),
// //                                 ),
// //                                 DataCell(
// //                                   Row(
// //                                     mainAxisSize: MainAxisSize.min,
// //                                     children: [
// //                                       IconButton(
// //                                         icon: Icon(Icons.edit),
// //                                         onPressed: () => _showEmployeeDialog(employee: employee),
// //                                       ),
// //                                       IconButton(
// //                                         icon: Icon(Icons.delete, color: Colors.red),
// //                                         onPressed: () => _deleteEmployee(employee),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             );
// //                           }).toList(),
// //                         ),
// //                       ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   Future<void> _showEmployeeDialog({Employee? employee}) async {
// //     final formKey = GlobalKey<FormState>();
// //     final employeeIdController = TextEditingController(text: employee?.employeeId ?? '');
// //     final fullNameController = TextEditingController(text: employee?.fullName ?? '');
// //     final departmentController = TextEditingController(text: employee?.department ?? '');
// //     final positionController = TextEditingController(text: employee?.position ?? '');
// //     final emailController = TextEditingController(text: employee?.email ?? '');
// //     User? selectedManager;
    
// //     if (employee?.managerId != null) {
// //       try {
// //         selectedManager = _managers.firstWhere((m) => m.id == employee!.managerId);
// //       } catch (e) {
// //         selectedManager = _managers.isNotEmpty ? _managers.first : null;
// //       }
// //     }
    
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text(employee == null ? 'Add Employee' : 'Edit Employee'),
// //         content: SizedBox(
// //           width: 400,
// //           height: 400,
// //           child: Form(
// //             key: formKey,
// //             child: ListView(
// //               children: [
// //                 TextFormField(
// //                   controller: employeeIdController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Employee ID',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                   validator: (value) => value?.isEmpty == true ? 'Required' : null,
// //                 ),
// //                 SizedBox(height: 15),
// //                 TextFormField(
// //                   controller: fullNameController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Full Name',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                   validator: (value) => value?.isEmpty == true ? 'Required' : null,
// //                 ),
// //                 SizedBox(height: 15),
// //                 TextFormField(
// //                   controller: departmentController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Department',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                   validator: (value) => value?.isEmpty == true ? 'Required' : null,
// //                 ),
// //                 SizedBox(height: 15),
// //                 TextFormField(
// //                   controller: positionController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Position',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                 ),
// //                 SizedBox(height: 15),
// //                 TextFormField(
// //                   controller: emailController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Email',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                   keyboardType: TextInputType.emailAddress,
// //                 ),
// //                 SizedBox(height: 15),
// //                 DropdownButtonFormField<User>(
// //                   value: selectedManager,
// //                   decoration: InputDecoration(
// //                     labelText: 'Manager',
// //                     border: OutlineInputBorder(),
// //                   ),
// //                   items: _managers.map((manager) {
// //                     return DropdownMenuItem(
// //                       value: manager,
// //                       child: Text(manager.fullName),
// //                     );
// //                   }).toList(),
// //                   onChanged: (value) {
// //                     selectedManager = value;
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () async {
// //               if (formKey.currentState!.validate()) {
// //                 await _saveEmployee(
// //                   employee,
// //                   employeeIdController.text,
// //                   fullNameController.text,
// //                   departmentController.text,
// //                   positionController.text,
// //                   emailController.text,
// //                   selectedManager?.id,
// //                 );
// //                 Navigator.pop(context);
// //               }
// //             },
// //             child: Text(employee == null ? 'Add' : 'Update'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   Future<void> _saveEmployee(Employee? existingEmployee, String employeeId,
// //       String fullName, String department, String position, String email, int? managerId) async {
// //     final db = await DatabaseHelper().database;
    
// //     try {
// //       Map<String, dynamic> employeeData = {
// //         'employee_id': employeeId,
// //         'full_name': fullName,
// //         'department': department,
// //         'position': position.isEmpty ? null : position,
// //         'email': email.isEmpty ? null : email,
// //         'manager_id': managerId,
// //       };
      
// //       if (existingEmployee == null) {
// //         await db.insert('employees', employeeData);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Employee added successfully')),
// //         );
// //       } else {
// //         await db.update(
// //           'employees',
// //           employeeData,
// //           where: 'id = ?',
// //           whereArgs: [existingEmployee.id],
// //         );
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Employee updated successfully')),
// //         );
// //       }
      
// //       _loadData();
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Failed to save employee: ${e.toString()}'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }
  
// //   Future<void> _deleteEmployee(Employee employee) async {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('Delete Employee'),
// //         content: Text('Are you sure you want to delete ${employee.fullName}?'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () async {
// //               try {
// //                 final db = await DatabaseHelper().database;
// //                 await db.delete('employees', where: 'id = ?', whereArgs: [employee.id]);
// //                 Navigator.pop(context);
// //                 _loadData();
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(content: Text('Employee deleted successfully')),
// //                 );
// //               } catch (e) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(
// //                     content: Text('Failed to delete employee: ${e.toString()}'),
// //                     backgroundColor: Colors.red,
// //                   ),
// //                 );
// //               }
// //             },
// //             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //             child: Text('Delete', style: TextStyle(color: Colors.white)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // } 
// import 'package:flutter/material.dart';
// import 'package:rewards_recognition_app/database/databasehelper.dart';
// import '../models/models.dart';
// import 'package:excel/excel.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';

// class ReportsPage extends StatefulWidget {
//   final User user;
  
//   ReportsPage({required this.user});
  
//   @override
//   _ReportsPageState createState() => _ReportsPageState();
// }

// class _ReportsPageState extends State<ReportsPage> {
//   Map<String, dynamic> _reportData = {};
//   bool _isLoading = true;
  
//   // Filter variables
//   DateTime? _fromDate;
//   DateTime? _toDate;
//   String? _selectedDepartment;
//   List<String> _departments = [];
  
//   @override
//   void initState() {
//     super.initState();
//     _loadDepartments();
//     _loadReportData();
//   }
  
//   Future<void> _loadDepartments() async {
//     final db = await DatabaseHelper().database;
//     final result = await db.rawQuery('''
//       SELECT DISTINCT department 
//       FROM employees 
//       WHERE department IS NOT NULL 
//       ORDER BY department
//     ''');
    
//     setState(() {
//       _departments = result.map((e) => e['department'] as String).toList();
//     });
//   }
  
//   Future<void> _loadReportData() async {
//     final db = await DatabaseHelper().database;
    
//     // Department-wise rewards
//     final deptRewards = await db.rawQuery('''
//       SELECT e.department, COUNT(r.id) as reward_count,
//              COALESCE(SUM(rc.monetary_value), 0) as total_value
//       FROM employees e
//       LEFT JOIN rewards r ON e.id = r.employee_id AND r.status = 'approved'
//       LEFT JOIN reward_categories rc ON r.category_id = rc.id
//       GROUP BY e.department
//       ORDER BY reward_count DESC
//     ''');
    
//     // Category-wise distribution
//     final categoryDist = await db.rawQuery('''
//       SELECT rc.name, COUNT(r.id) as count,
//              COALESCE(SUM(rc.monetary_value), 0) as total_value
//       FROM reward_categories rc
//       LEFT JOIN rewards r ON rc.id = r.category_id AND r.status = 'approved'
//       GROUP BY rc.id, rc.name
//       ORDER BY count DESC
//     ''');
    
//     // Monthly trends (last 6 months)
//     final monthlyTrends = await db.rawQuery('''
//       SELECT strftime('%Y-%m', r.submitted_at) as month,
//              COUNT(r.id) as submissions,
//              SUM(CASE WHEN r.status = 'approved' THEN 1 ELSE 0 END) as approved
//       FROM rewards r
//       WHERE r.submitted_at >= date('now', '-6 months')
//       GROUP BY strftime('%Y-%m', r.submitted_at)
//       ORDER BY month
//     ''');
    
//     setState(() {
//       _reportData = {
//         'departmentRewards': deptRewards,
//         'categoryDistribution': categoryDist,
//         'monthlyTrends': monthlyTrends,
//       };
//       _isLoading = false;
//     });
//   }
  
// Future<void> _downloadExcelReport() async {
//   // Validate date selection
//   if (_fromDate == null || _toDate == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Please select both From and To dates'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//     return;
//   }
  
//   try {
//     setState(() => _isLoading = true);
    
//     final db = await DatabaseHelper().database;
    
//     // Prepare date strings for query
//     String fromDateStr = DateFormat('yyyy-MM-dd').format(_fromDate!);
//     String toDateStr = DateFormat('yyyy-MM-dd').format(_toDate!);
    
//     // Build WHERE clause and arguments
//     String whereClause = "WHERE DATE(r.submitted_at) BETWEEN DATE(?) AND DATE(?)";
//     List<dynamic> whereArgs = [fromDateStr, toDateStr];
    
//     // Add department filter ONLY if a specific department is selected
//     if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
//       whereClause += " AND e.department = ?";
//       whereArgs.add(_selectedDepartment);
//     }
    
//     print('=== GENERATING EXCEL REPORT ===');
//     print('Date Range: $fromDateStr to $toDateStr');
//     print('Department Filter: ${_selectedDepartment ?? "ALL DEPARTMENTS"}');
//     print('WHERE Clause: $whereClause');
//     print('Arguments: $whereArgs');
    
//     // Fetch all reward records matching the filters
//     final rewardData = await db.rawQuery('''
//       SELECT 
//         e.employee_id,
//         e.full_name as employee_name,
//         e.email,
//         e.department,
//         e.position,
//         rc.name as reward_category,
//         rc.monetary_value,
//         r.reason as description,
//         r.submitted_at,
//         r.status,
//         r.approved_at,
//         approver1.full_name as level1_approver_name,
//         approver2.full_name as level2_approver_name,
//         approver3.full_name as level3_approver_name
//       FROM rewards r
//       INNER JOIN employees e ON r.employee_id = e.id
//       INNER JOIN reward_categories rc ON r.category_id = rc.id
//       LEFT JOIN users approver1 ON r.level1_approver = approver1.id
//       LEFT JOIN users approver2 ON r.level2_approver = approver2.id
//       LEFT JOIN users approver3 ON r.level3_approver = approver3.id
//       $whereClause
//       ORDER BY e.department, e.employee_id, r.submitted_at DESC
//     ''', whereArgs);
    
//     print('Records Found: ${rewardData.length}');
    
//     // Check if any data was found
//     if (rewardData.isEmpty) {
//       setState(() => _isLoading = false);
      
//       // Show detailed message
//       String message = 'No rewards found for the selected criteria:\n\n';
//       message += 'Date Range: ${DateFormat('dd-MMM-yyyy').format(_fromDate!)} to ${DateFormat('dd-MMM-yyyy').format(_toDate!)}\n';
//       message += 'Department: ${_selectedDepartment ?? "All Departments"}\n\n';
//       message += 'Please verify:\n';
//       message += '• Rewards exist in this date range\n';
//       message += '• Date range includes reward submission dates\n';
//       message += '• Selected department has rewards';
      
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.info_outline, color: Colors.orange),
//               SizedBox(width: 10),
//               Text('No Data Found'),
//             ],
//           ),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }
    
//     print('Creating Excel file with ${rewardData.length} records...');
    
//     // Create Excel workbook
//     var excel = Excel.createExcel();
//     excel.delete('Sheet1');
    
//     // ==================== SHEET 1: EMPLOYEE REWARDS ====================
//     Sheet sheetRewards = excel['Employee Rewards'];
    
//     // Define column headers
//     List<String> headers = [
//       'Employee ID',
//       'Employee Name',
//       'Email',
//       'Department',
//       'Position',
//       'Reward Category',
//       'Monetary Value (₹)',
//       'Description',
//       'Submitted Date',
//       'Status',
//       'Approved Date',
//       'L1 Approver',
//       'L2 Approver',
//       'L3 Approver'
//     ];
    
//     // Add headers with styling
//     for (int col = 0; col < headers.length; col++) {
//       var cell = sheetRewards.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
//       cell.value = TextCellValue(headers[col]);
//       cell.cellStyle = CellStyle(
//         bold: true,
//         backgroundColorHex: ExcelColor.blue,
//         fontColorHex: ExcelColor.white,
//       );
//     }
    
//     // Add data rows
//     for (int rowIdx = 0; rowIdx < rewardData.length; rowIdx++) {
//       var record = rewardData[rowIdx];
      
//       // Format dates nicely
//       String submittedDate = record['submitted_at']?.toString() ?? '';
//       if (submittedDate.isNotEmpty) {
//         try {
//           DateTime dt = DateTime.parse(submittedDate);
//           submittedDate = DateFormat('dd-MMM-yyyy HH:mm').format(dt);
//         } catch (e) {
//           // Keep original if parsing fails
//         }
//       }
      
//       String approvedDate = record['approved_at']?.toString() ?? '';
//       if (approvedDate.isNotEmpty) {
//         try {
//           DateTime dt = DateTime.parse(approvedDate);
//           approvedDate = DateFormat('dd-MMM-yyyy HH:mm').format(dt);
//         } catch (e) {
//           approvedDate = '';
//         }
//       }
      
//       // Prepare row data
//       List<String> rowData = [
//         record['employee_id']?.toString() ?? '',
//         record['employee_name']?.toString() ?? '',
//         record['email']?.toString() ?? '',
//         record['department']?.toString() ?? '',
//         record['position']?.toString() ?? '',
//         record['reward_category']?.toString() ?? '',
//         record['monetary_value']?.toString() ?? '0',
//         record['description']?.toString() ?? '',
//         submittedDate,
//         record['status']?.toString().toUpperCase() ?? '',
//         approvedDate,
//         record['level1_approver_name']?.toString() ?? 'N/A',
//         record['level2_approver_name']?.toString() ?? 'N/A',
//         record['level3_approver_name']?.toString() ?? 'N/A',
//       ];
      
//       // Write data to cells
//       for (int col = 0; col < rowData.length; col++) {
//         var cell = sheetRewards.cell(CellIndex.indexByColumnRow(
//           columnIndex: col, 
//           rowIndex: rowIdx + 1
//         ));
//         cell.value = TextCellValue(rowData[col]);
        
//         // Color code based on status
//         if (col == 9) { // Status column
//           String status = rowData[col].toLowerCase();
//           if (status == 'approved') {
//             cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.green100);
//           } else if (status == 'pending') {
//             cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.yellow);
//           } else if (status == 'rejected') {
//             cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.red100);
//           }
//         }
//       }
//     }
    
//     print('Added ${rewardData.length} data rows to Employee Rewards sheet');
    
//     // ==================== SHEET 2: SUMMARY ====================
//     Sheet sheetSummary = excel['Summary'];
//     int row = 0;
    
//     // Title
//     var titleCell = sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++));
//     titleCell.value = TextCellValue('REWARDS REPORT SUMMARY');
//     titleCell.cellStyle = CellStyle(bold: true, fontSize: 18);
//     row++;
    
//     // Report Parameters Section
//     sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
//       .value = TextCellValue('REPORT PARAMETERS');
    
//     var params = [
//       ['From Date:', DateFormat('dd-MMM-yyyy').format(_fromDate!)],
//       ['To Date:', DateFormat('dd-MMM-yyyy').format(_toDate!)],
//       ['Department:', _selectedDepartment ?? 'All Departments'],
//       ['Generated On:', DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now())],
//     ];
    
//     for (var param in params) {
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//         .value = TextCellValue(param[0]);
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row++))
//         .value = TextCellValue(param[1]);
//     }
//     row++;
    
//     // Calculate statistics
//     int totalRewards = rewardData.length;
//     int approvedCount = rewardData.where((r) => r['status']?.toString().toLowerCase() == 'approved').length;
//     int pendingCount = rewardData.where((r) => r['status']?.toString().toLowerCase() == 'pending').length;
//     int rejectedCount = rewardData.where((r) => r['status']?.toString().toLowerCase() == 'rejected').length;
    
//     double totalValue = 0.0;
//     double approvedValue = 0.0;
    
//     for (var r in rewardData) {
//       double value = double.tryParse(r['monetary_value']?.toString() ?? '0') ?? 0.0;
//       totalValue += value;
//       if (r['status']?.toString().toLowerCase() == 'approved') {
//         approvedValue += value;
//       }
//     }
    
//     // Statistics Section
//     sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
//       .value = TextCellValue('SUMMARY STATISTICS');
    
//     var stats = [
//       ['Total Rewards Submitted:', totalRewards.toString()],
//       ['Approved Rewards:', '$approvedCount (${totalRewards > 0 ? (approvedCount * 100 / totalRewards).toStringAsFixed(1) : 0}%)'],
//       ['Pending Rewards:', '$pendingCount (${totalRewards > 0 ? (pendingCount * 100 / totalRewards).toStringAsFixed(1) : 0}%)'],
//       ['Rejected Rewards:', '$rejectedCount (${totalRewards > 0 ? (rejectedCount * 100 / totalRewards).toStringAsFixed(1) : 0}%)'],
//       ['Total Monetary Value:', '₹${totalValue.toStringAsFixed(2)}'],
//       ['Approved Value:', '₹${approvedValue.toStringAsFixed(2)}'],
//     ];
    
//     for (var stat in stats) {
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//         .value = TextCellValue(stat[0]);
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row++))
//         .value = TextCellValue(stat[1]);
//     }
//     row += 2;
    
//     // Department-wise Breakdown
//     if (_selectedDepartment == null) {
//       Map<String, int> deptCount = {};
//       Map<String, double> deptValue = {};
      
//       for (var r in rewardData) {
//         String dept = r['department']?.toString() ?? 'Unknown';
//         double value = double.tryParse(r['monetary_value']?.toString() ?? '0') ?? 0.0;
//         deptCount[dept] = (deptCount[dept] ?? 0) + 1;
//         deptValue[dept] = (deptValue[dept] ?? 0.0) + value;
//       }
      
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
//         .value = TextCellValue('DEPARTMENT-WISE BREAKDOWN');
      
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//         .value = TextCellValue('Department');
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//         .value = TextCellValue('Count');
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
//         .value = TextCellValue('Total Value (₹)');
      
//       deptCount.forEach((dept, count) {
//         sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//           .value = TextCellValue(dept);
//         sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//           .value = TextCellValue(count.toString());
//         sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
//           .value = TextCellValue('₹${deptValue[dept]?.toStringAsFixed(2)}');
//       });
//       row++;
//     }
    
//     // Category-wise Breakdown
//     Map<String, int> categoryCount = {};
//     Map<String, double> categoryValue = {};
    
//     for (var r in rewardData) {
//       String category = r['reward_category']?.toString() ?? 'Unknown';
//       double value = double.tryParse(r['monetary_value']?.toString() ?? '0') ?? 0.0;
//       categoryCount[category] = (categoryCount[category] ?? 0) + 1;
//       categoryValue[category] = (categoryValue[category] ?? 0.0) + value;
//     }
    
//     sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
//       .value = TextCellValue('CATEGORY-WISE BREAKDOWN');
    
//     sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//       .value = TextCellValue('Reward Category');
//     sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//       .value = TextCellValue('Count');
//     sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
//       .value = TextCellValue('Total Value (₹)');
    
//     categoryCount.forEach((category, count) {
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//         .value = TextCellValue(category);
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//         .value = TextCellValue(count.toString());
//       sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
//         .value = TextCellValue('₹${categoryValue[category]?.toStringAsFixed(2)}');
//     });
    
//     print('Summary sheet created');
    
//     // ==================== SAVE FILE ====================
//     var fileBytes = excel.save();
    
//     if (fileBytes == null || fileBytes.isEmpty) {
//       throw Exception('Failed to generate Excel file bytes');
//     }
    
//     print('Excel file generated: ${fileBytes.length} bytes');
    
//     // Determine save location
//     String downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
//     Directory downloadsDir = Directory(downloadsPath);
    
//     if (!downloadsDir.existsSync()) {
//       downloadsDir = await getApplicationDocumentsDirectory();
//     }
    
//     // Create filename
//     String fileName = 'Rewards_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
//     String filePath = '${downloadsDir.path}\\$fileName';
    
//     // Write file
//     File file = File(filePath);
//     await file.writeAsBytes(fileBytes);
    
//     print('File saved: $filePath');
//     print('File size: ${file.lengthSync()} bytes');
    
//     setState(() => _isLoading = false);
    
//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('✓ Report Generated Successfully!', 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 4),
//             Text('${rewardData.length} employee rewards exported'),
//             Text('Saved to: $fileName'),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 6),
//         // action: SnackBarAction(
//         //   label: 'OPEN FOLDER',
//         //   textColor: Colors.white,
//         //   onPressed: () async {
//         //     // Optional: Open file explorer to the downloads folder
//         //     // You can use Process.run to open explorer
//         //   },
//         // ),
//       ),
//     );
    
//   } catch (e, stackTrace) {
//     setState(() => _isLoading = false);
//     print('ERROR: $e');
//     print('STACK: $stackTrace');
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Error generating report: $e'),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 5),
//       ),
//     );
//   }
// }
//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isFromDate ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now()),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
    
//     if (picked != null) {
//       setState(() {
//         if (isFromDate) {
//           _fromDate = picked;
//         } else {
//           _toDate = picked;
//         }
//       });
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Reports & Analytics',
//             style: Theme.of(context).textTheme.headlineLarge,
//           ),
//           SizedBox(height: 20),
          
//           // Filter Section
//           Card(
//             elevation: 4,
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Download Excel Report',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: InkWell(
//                           onTap: () => _selectDate(context, true),
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               labelText: 'From Date',
//                               border: OutlineInputBorder(),
//                               suffixIcon: Icon(Icons.calendar_today),
//                             ),
//                             child: Text(
//                               _fromDate != null
//                                   ? DateFormat('dd-MM-yyyy').format(_fromDate!)
//                                   : 'Select date',
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: InkWell(
//                           onTap: () => _selectDate(context, false),
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               labelText: 'To Date',
//                               border: OutlineInputBorder(),
//                               suffixIcon: Icon(Icons.calendar_today),
//                             ),
//                             child: Text(
//                               _toDate != null
//                                   ? DateFormat('dd-MM-yyyy').format(_toDate!)
//                                   : 'Select date',
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             labelText: 'Department',
//                             border: OutlineInputBorder(),
//                           ),
//                           value: _selectedDepartment,
//                           items: [
//                             DropdownMenuItem(
//                               value: null,
//                               child: Text('All Departments'),
//                             ),
//                             ..._departments.map((dept) => DropdownMenuItem(
//                               value: dept,
//                               child: Text(dept),
//                             )),
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedDepartment = value;
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _downloadExcelReport,
//                     icon: Icon(Icons.download),
//                     label: Text('Download Excel Report'),
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           SizedBox(height: 20),
//           Expanded(
//             child: _isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : ListView(
//                     children: [
//                       _buildDepartmentReport(),
//                       SizedBox(height: 30),
//                       _buildCategoryReport(),
//                       SizedBox(height: 30),
//                       _buildTrendsReport(),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildDepartmentReport() {
//     final data = _reportData['departmentRewards'] as List<Map<String, dynamic>>;
    
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Department-wise Rewards',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             SizedBox(height: 15),
//             DataTable(
//               columns: [
//                 DataColumn(label: Text('Department')),
//                 DataColumn(label: Text('Rewards Count')),
//                 DataColumn(label: Text('Total Value (₹)')),
//               ],
//               rows: data.map((dept) {
//                 return DataRow(cells: [
//                   DataCell(Text(dept['department'] ?? 'Unknown')),
//                   DataCell(Text(dept['reward_count'].toString())),
//                   DataCell(Text('₹${dept['total_value'].toStringAsFixed(0)}')),
//                 ]);
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildCategoryReport() {
//     final data = _reportData['categoryDistribution'] as List<Map<String, dynamic>>;
    
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Category Distribution',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             SizedBox(height: 15),
//             DataTable(
//               columns: [
//                 DataColumn(label: Text('Category')),
//                 DataColumn(label: Text('Count')),
//                 DataColumn(label: Text('Total Value (₹)')),
//               ],
//               rows: data.map((cat) {
//                 return DataRow(cells: [
//                   DataCell(Text(cat['name'])),
//                   DataCell(Text(cat['count'].toString())),
//                   DataCell(Text('₹${cat['total_value'].toStringAsFixed(2)}')),
//                 ]);
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildTrendsReport() {
//     final data = _reportData['monthlyTrends'] as List<Map<String, dynamic>>;
    
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Monthly Trends',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             SizedBox(height: 15),
//             if (data.isEmpty)
//               Text('No data available for the last 6 months')
//             else
//               DataTable(
//                 columns: [
//                   DataColumn(label: Text('Month')),
//                   DataColumn(label: Text('Submissions')),
//                   DataColumn(label: Text('Approved')),
//                   DataColumn(label: Text('Approval Rate')),
//                 ],
//                 rows: data.map((month) {
//                   int submissions = month['submissions'] ?? 0;
//                   int approved = month['approved'] ?? 0;
//                   double rate = submissions > 0 ? (approved / submissions * 100) : 0;
                  
//                   return DataRow(cells: [
//                     DataCell(Text(month['month'] ?? '')),
//                     DataCell(Text(submissions.toString())),
//                     DataCell(Text(approved.toString())),
//                     DataCell(Text('${rate.toStringAsFixed(1)}%')),
//                   ]);
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }