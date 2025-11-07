// import 'package:flutter/material.dart';
// import 'package:rewards_recognition_app/database/databasehelper.dart';
// import '../models/models.dart';

// class SubmitRewardPage extends StatefulWidget {
//   final User user;

//   SubmitRewardPage({required this.user});

//   @override
//   _SubmitRewardPageState createState() => _SubmitRewardPageState();
// }

// class _SubmitRewardPageState extends State<SubmitRewardPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _reasonController = TextEditingController();

//   Employee? _selectedEmployee;
//   RewardCategory? _selectedCategory;
//   List<Employee> _employees = [];
//   List<RewardCategory> _categories = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     final db = await DatabaseHelper().database;

//     final employeeData = await db.query('employees');
//     _employees = employeeData.map((e) => Employee.fromMap(e)).toList();

//     final categoryData = await db.query('reward_categories');
//     _categories = categoryData.map((c) => RewardCategory.fromMap(c)).toList();

//     setState(() {});
//   }

//   void _resetForm() {
//     _reasonController.clear();
//     setState(() {
//       _selectedEmployee = null;
//       _selectedCategory = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(20),
//       child: Card(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Submit New Reward',
//                 style: Theme.of(context).textTheme.headlineLarge,
//               ),
//               SizedBox(height: 20),
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: ListView(
//                     children: [
//                       // Employee Selection
//                       DropdownButtonFormField<Employee>(
//                         key: ValueKey(_selectedEmployee),
//                         decoration: InputDecoration(
//                           labelText: 'Select Employee',
//                           border: OutlineInputBorder(),
//                         ),
//                         value: _selectedEmployee,
//                         items: _employees.map((employee) {
//                           return DropdownMenuItem(
//                             value: employee,
//                             child: Text(
//                                 '${employee.fullName} (${employee.employeeId})'),
//                           );
//                         }).toList(),
//                         onChanged: (employee) async {
//                           setState(() {
//                             _selectedEmployee = employee;
//                           });

//                           if (employee != null) {
//                             await _checkEmployeeRewards(employee);
//                           }
//                         },
//                         validator: (value) =>
//                             value == null ? 'Please select an employee' : null,
//                       ),
//                       SizedBox(height: 20),

//                       // Category Selection
//                       DropdownButtonFormField<RewardCategory>(
//                         key: ValueKey(_selectedCategory),
//                         decoration: const InputDecoration(
//                           labelText: 'Reward Category',
//                           border: OutlineInputBorder(),
//                         ),
//                         value: _selectedCategory,
//                         items: _categories.map((category) {
//                           return DropdownMenuItem(
//                             value: category,
//                             child: FittedBox(
//                               fit: BoxFit.scaleDown,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(category.name,
//                                       style: TextStyle(fontSize: 16)),
//                                   Text(
//                                     'Level ${category.approvalLevel} approval required',
//                                     style: TextStyle(
//                                         fontSize: 14, color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (category) async {
//                           setState(() {
//                             _selectedCategory = category;
//                           });
                          
//                           // ✅ Check if this category already awarded
//                           if (_selectedEmployee != null && category != null) {
//                             await _checkCategoryDuplication(_selectedEmployee!, category);
//                           }
//                         },
//                         validator: (value) => value == null
//                             ? 'Please select a reward category'
//                             : null,
//                       ),
//                       SizedBox(height: 20),

//                       // Reason Field
//                       TextFormField(
//                         controller: _reasonController,
//                         decoration: InputDecoration(
//                           labelText: 'Reason for Recognition',
//                           hintText:
//                               'Describe why this employee deserves this reward...',
//                           border: OutlineInputBorder(),
//                         ),
//                         maxLines: 5,
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Please provide a reason';
//                           }
//                           if (value.trim().length < 20) {
//                             return 'Minimum 20 characters required';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 20),

//                       if (_selectedCategory != null) ...[
//                         Card(
//                           color: Theme.of(context).colorScheme.surfaceVariant,
//                           child: Padding(
//                             padding: EdgeInsets.all(15),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Category Details',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                                     )),
//                                 SizedBox(height: 5),
//                                 Text(
//                                     'Description: ${_selectedCategory!.description ?? 'N/A'}',
//                                      style: TextStyle(
//                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
//                                      )),
//                                 Text(
//                                     'Approval Level: Level ${_selectedCategory!.approvalLevel}',
//                                     style: TextStyle(
//                                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                                     )),
//                                 if (_selectedCategory!.monetaryValue != null)
//                                   Text(
//                                       'Value: ₹${_selectedCategory!.monetaryValue!.toStringAsFixed(0)}',
//                                       style: TextStyle(
//                                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                                       )),
//                                 SizedBox(height: 8),
//                                 Container(
//                                   padding: EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange.shade50,
//                                     borderRadius: BorderRadius.circular(4),
//                                     border: Border.all(color: Colors.orange.shade200),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '⚠️ Award Rules:',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.orange.shade900,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         '• Maximum 2 awards per employee per year',
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.orange.shade800,
//                                         ),
//                                       ),
//                                       Text(
//                                         '• Same category can only be awarded ONCE per year',
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.orange.shade800,
//                                         ),
//                                       ),
//                                       Text(
//                                         '• Example: If Platinum awarded, cannot award Platinum again',
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.orange.shade800,
//                                           fontStyle: FontStyle.italic,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                       ],

//                       // Submit Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _submitReward,
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 15),
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: _isLoading
//                               ? CircularProgressIndicator(color: Colors.white)
//                               : Text('Submit Reward'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ NEW: Check employee's existing rewards
//   Future<void> _checkEmployeeRewards(Employee employee) async {
//     final db = await DatabaseHelper().database;
//     int currentYear = DateTime.now().year;
    
//     // Get total count and categories awarded
//     final rewards = await db.rawQuery('''
//       SELECT rc.name as category_name, r.status
//       FROM rewards r
//       JOIN reward_categories rc ON r.category_id = rc.id
//       WHERE r.employee_id = ? 
//       AND strftime('%Y', r.submitted_at) = ?
//       AND r.status IN ('pending', 'approved')
//     ''', [employee.id, currentYear.toString()]);
    
//     int count = rewards.length;
//     List<String> awardedCategories = rewards.map((r) => r['category_name'] as String).toList();
    
//     if (count >= 2) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               '⚠️ Employee already has 2 rewards in $currentYear\nAwarded: ${awardedCategories.join(", ")}'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 4),
//         ),
//       );
//     } else if (count == 1) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'ℹ️ Employee has $count/2 rewards for $currentYear\nAwarded: ${awardedCategories.join(", ")}'),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 4),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('✅ Employee has no rewards yet in $currentYear'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   // ✅ NEW: Check if selected category already awarded to employee
//   Future<void> _checkCategoryDuplication(Employee employee, RewardCategory category) async {
//     final db = await DatabaseHelper().database;
//     int currentYear = DateTime.now().year;
    
//     final existingCategoryReward = await db.rawQuery('''
//       SELECT COUNT(*) as count 
//       FROM rewards 
//       WHERE employee_id = ? 
//       AND category_id = ?
//       AND strftime('%Y', submitted_at) = ?
//       AND status IN ('pending', 'approved')
//     ''', [employee.id, category.id, currentYear.toString()]);
    
//     int categoryCount = existingCategoryReward.first['count'] as int;
    
//     if (categoryCount > 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               '❌ ${category.name} already awarded to this employee in $currentYear!\nPlease select a different category.'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 4),
//         ),
//       );
//     }
//   }

//   Future<void> _submitReward() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);

//       try {
//         final db = await DatabaseHelper().database;
//         int currentYear = DateTime.now().year;

//         // ✅ CHECK 1: Total rewards limit (max 2 per year)
//         final rewardCount = await db.rawQuery('''
//           SELECT COUNT(*) as count 
//           FROM rewards 
//           WHERE employee_id = ? 
//           AND strftime('%Y', submitted_at) = ?
//           AND status IN ('pending', 'approved')
//         ''', [_selectedEmployee!.id, currentYear.toString()]);
//         int count = rewardCount.first['count'] as int;

//         if (count >= 2) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   '❌ Cannot submit: Employee already has 2 rewards in $currentYear'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           setState(() => _isLoading = false);
//           return;
//         }

//         // ✅ CHECK 2: Category duplication (same category can't be awarded twice)
//         final categoryCheck = await db.rawQuery('''
//           SELECT COUNT(*) as count 
//           FROM rewards 
//           WHERE employee_id = ? 
//           AND category_id = ?
//           AND strftime('%Y', submitted_at) = ?
//           AND status IN ('pending', 'approved')
//         ''', [_selectedEmployee!.id, _selectedCategory!.id, currentYear.toString()]);
//         int categoryCount = categoryCheck.first['count'] as int;

//         if (categoryCount > 0) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   '❌ Cannot submit: ${_selectedCategory!.name} already awarded to this employee in $currentYear'),
//               backgroundColor: Colors.red,
//               duration: Duration(seconds: 4),
//             ),
//           );
//           setState(() => _isLoading = false);
//           return;
//         }

//         // ✅ CHECK 3: Level 1 approver exists
//         final approverQuery = await db.query(
//           'users',
//           where: 'department = ? AND role = ?',
//           whereArgs: [_selectedEmployee!.department, 'approver_level1'],
//         );

//         if (approverQuery.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   '❌ No Level 1 approver found for ${_selectedEmployee!.department} department.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           setState(() => _isLoading = false);
//           return;
//         }

//         final level1ApproverId = approverQuery.first['id'];

//         // ✅ All checks passed - insert reward
//         await db.insert('rewards', {
//           'employee_id': _selectedEmployee!.id,
//           'category_id': _selectedCategory!.id,
//           'nominated_by': widget.user.id,
//           'reason': _reasonController.text.trim(),
//           'submitted_at': DateTime.now().toIso8601String(),
//           'level1_approver': level1ApproverId,
//           'level1_status': 'pending',
//           'status': 'pending',
//           'current_approval_level': 1,
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('✅ Reward submitted successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         _resetForm();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Failed to submit reward: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       setState(() => _isLoading = false);
//     }
//   }
// }
