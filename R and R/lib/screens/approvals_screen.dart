import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import '../models/models.dart';

class ApprovalsPage extends StatefulWidget {
  final User user;
  
  ApprovalsPage({required this.user});
  
  @override
  _ApprovalsPageState createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  List<Map<String, dynamic>> _pendingRewards = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPendingRewards();
  }
  
  Future<void> _loadPendingRewards() async {
    final db = await DatabaseHelper().database;
    
    String whereClause = 'WHERE r.status = "pending"';
    List<dynamic> whereArgs = [];
    
    String userRole = widget.user.role.toLowerCase();
    
    if (userRole == 'approver_level1') {
      // ✅ Corrected: Only 'approver_level1' can see L1 rewards in their department
      whereClause += ' AND r.current_approval_level = 1 AND e.department = ?';
      whereArgs.add(widget.user.department);
    } else if (userRole == 'approver_level2') {
      whereClause += ' AND r.current_approval_level = 2';
    } else if (userRole == 'approver_level3') {
      whereClause += ' AND r.current_approval_level = 3';
    } else if (userRole == 'admin') {
      // Admins can see all pending rewards
    } else {
      // Managers and other non-approver roles see nothing
      whereClause += ' AND 1 = 0';
    }

    String query = '''
      SELECT r.*, e.full_name as employee_name, e.employee_id, 
             e.department as employee_department, 
             rc.name as category_name, rc.approval_level,
             u.full_name as nominated_by_name
      FROM rewards r
      JOIN employees e ON r.employee_id = e.id
      JOIN reward_categories rc ON r.category_id = rc.id
      JOIN users u ON r.nominated_by = u.id
      $whereClause
      ORDER BY r.submitted_at DESC
    ''';
    
    final rewards = await db.rawQuery(query, whereArgs);
    
    setState(() {
      _pendingRewards = rewards;
      _isLoading = false;
    });
  }
  
  String _getEmptyStateMessage() {
    switch (widget.user.role.toLowerCase()) {
      case 'admin':
        return 'No pending approvals in system';
      case 'approver_level1':
        return 'No Level 1 approvals pending\nYou can approve rewards at the first level';
      case 'approver_level2':
        return 'No Level 2 approvals pending\nYou can approve rewards at the second level';
      case 'approver_level3':
        return 'No Level 3 approvals pending\nYou can approve rewards at the final level';
      case 'manager':
        return 'Managers have no approval permissions. Contact admin to be assigned as an approver.';
      default:
        return 'No approval permissions for your role\nContact admin for approval rights';
    }
  }
  
  bool _canUserApprove() {
    return ['admin', 'approver_level1', 'approver_level2', 'approver_level3']
        .contains(widget.user.role.toLowerCase());
  }
  
  bool _canUserApproveAtLevel(int level) {
    switch (widget.user.role.toLowerCase()) {
      case 'admin':
        return true; // Admin can approve at any level
      case 'approver_level1':
        return level == 1;
      case 'approver_level2':
        return level == 2;
      case 'approver_level3':
        return level == 3;
      default:
        return false;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _showApprovalDialog(Map<String, dynamic> reward, bool isApproval) async {
    if (!_canUserApproveAtLevel(reward['current_approval_level'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not authorized to approve at Level ${reward['current_approval_level']}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final commentController = TextEditingController();
    final formkey=GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isApproval ? Icons.check_circle : Icons.cancel,
              color: isApproval ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(isApproval ? 'Approve Reward' : 'Reject Reward'),
          ],
        ),
        content: Form(
          key: formkey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Employee: ${reward['employee_name']}'),
                    Text('Category: ${reward['category_name']}'),
                    Text('Current Level: ${reward['current_approval_level']}'),
                  ],
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Comment *',
                  border: OutlineInputBorder(),
                  hintText: 'Add your approval comment...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'comment is required';
                  }
                  else if (value.length<5){
                    return'comment should be at least 5 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formkey.currentState!.validate()) {
                await _processApproval(reward, isApproval, commentController.text);
                Navigator.pop(context);
              }
            },
            child: Text(isApproval ? 'Approve' : 'Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
    ));
  }
  
  Future<void> _processApproval(Map<String, dynamic> reward, bool isApproval, String comment) async {
    if (!_canUserApproveAtLevel(reward['current_approval_level'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unauthorized approval attempt blocked'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final db = await DatabaseHelper().database;
    
    try {
      int currentLevel = reward['current_approval_level'];
      int requiredLevel = reward['approval_level'];
      
      Map<String, dynamic> updateData = {};
      
      if (isApproval) {
        updateData['level${currentLevel}_status'] = 'approved';
        updateData['level${currentLevel}_approver'] = widget.user.id;
        if (comment.isNotEmpty) {
          updateData['level${currentLevel}_comment'] = comment;
        }
        
        if (currentLevel >= requiredLevel) {
          updateData['status'] = 'approved';
          updateData['approved_at'] = DateTime.now().toIso8601String();
        } else {
          updateData['current_approval_level'] = currentLevel + 1;
        }
      } else {
        updateData['status'] = 'rejected';
        updateData['level${currentLevel}_status'] = 'rejected';
        updateData['level${currentLevel}_approver'] = widget.user.id;
        if (comment.isNotEmpty) {
          updateData['level${currentLevel}_comment'] = comment;
        }
      }
      
      await db.update(
        'rewards',
        updateData,
        where: 'id = ?',
        whereArgs: [reward['id']],
      );
      
      String message = isApproval 
          ? currentLevel >= requiredLevel 
              ? 'Reward FINALLY approved and granted!'
              : 'Reward approved - moved to Level ${currentLevel + 1}'
          : 'Reward rejected and removed from workflow';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isApproval ? Colors.green : Colors.orange,
        ),
      );
      
      _loadPendingRewards(); // Reload the list
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process approval: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pending Approvals',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Spacer(),
              Chip(
                label: Text('Role: ${widget.user.role.toUpperCase()}'),
                backgroundColor: const Color.fromARGB(255, 67, 161, 239),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _pendingRewards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(_getEmptyStateMessage()),
                            SizedBox(height: 10),
                            Text(
                              'Your role: ${widget.user.role.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (!_canUserApprove()) ...[
                              SizedBox(height: 10),
                              Text(
                                'Contact admin to get approval permissions',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pendingRewards.length,
                        itemBuilder: (context, index) {
                          final reward = _pendingRewards[index];
                          return _buildApprovalCard(reward);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> reward) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${reward['employee_name']} (${reward['employee_id']})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      label: Text('Level ${reward['current_approval_level']}'),
                      backgroundColor: const Color.fromARGB(255, 86, 169, 237),
                    ),
                    SizedBox(width: 8),
                    Chip(
                      label: Text('Requires L${reward['approval_level']}'),
                      backgroundColor: const Color.fromARGB(255, 227, 162, 42),
                      labelStyle: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Category: ${reward['category_name']}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 5),
            Text('Nominated by: ${reward['nominated_by_name']}'),
            SizedBox(height: 10),
            Text('Reason:', style: TextStyle(fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface, // ✅ Theme-aware text color
)),
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(top: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant, // ✅ Theme-aware background
      borderRadius: BorderRadius.circular(6),
    ),
              child: Text(
                reward['reason'],
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Submitted: ${_formatDate(reward['submitted_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showApprovalDialog(reward, false),
                      child: Text('Reject'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _showApprovalDialog(reward, true),
                      child: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}