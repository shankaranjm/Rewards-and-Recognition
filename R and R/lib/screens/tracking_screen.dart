import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import '../models/models.dart';


class TrackingPage extends StatefulWidget {
  final User user;
  
  TrackingPage({required this.user});
  
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allRewards = [];
  List<Map<String, dynamic>> _myRewards = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRewards();
  }
  
  Future<void> _loadRewards() async {
    final db = await DatabaseHelper().database;
    
    // Load all rewards (for admin/managers)
    final allRewards = await db.rawQuery('''
      SELECT r.*, e.full_name as employee_name, e.employee_id,
             rc.name as category_name, rc.monetary_value,
             u.full_name as nominated_by_name
      FROM rewards r
      JOIN employees e ON r.employee_id = e.id
      JOIN reward_categories rc ON r.category_id = rc.id
      JOIN users u ON r.nominated_by = u.id
      ORDER BY r.submitted_at DESC
    ''');
    
    // Load user's submitted rewards
    final myRewards = await db.rawQuery('''
      SELECT r.*, e.full_name as employee_name, e.employee_id,
             rc.name as category_name, rc.monetary_value
      FROM rewards r
      JOIN employees e ON r.employee_id = e.id
      JOIN reward_categories rc ON r.category_id = rc.id
      WHERE r.nominated_by = ?
      ORDER BY r.submitted_at DESC
    ''', [widget.user.id]);
    
    setState(() {
      _allRewards = allRewards;
      _myRewards = myRewards;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Submissions'),
            Tab(text: 'All Rewards'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRewardsList(_myRewards, 'No rewards submitted yet'),
              _buildRewardsList(_allRewards, 'No rewards in system'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRewardsList(List<Map<String, dynamic>> rewards, String emptyMessage) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 10),
            Text(emptyMessage),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return _buildTrackingCard(reward);
      },
    );
  }
  
  Widget _buildTrackingCard(Map<String, dynamic> reward) {
    Color statusColor;
    IconData statusIcon;
    
    switch (reward['status']) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }
    
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
                    Icon(statusIcon, color: statusColor, size: 16),
                    SizedBox(width: 5),
                    Text(
                      reward['status'].toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Category: ${reward['category_name']}'),
            if (reward['monetary_value'] != null)
              Text('Value: ₹${reward['monetary_value'].toStringAsFixed(0)}'),
            SizedBox(height: 5),
            Text('Submitted: ${_formatDate(reward['submitted_at'])}'),
            if (reward['approved_at'] != null)
              Text('Approved: ${_formatDate(reward['approved_at'])}'),
            SizedBox(height: 10),
            ExpansionTile(
              title: Text('View Details'),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(reward['reason']),
                      SizedBox(height: 10),
                      _buildApprovalProgress(reward),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildApprovalProgress(Map<String, dynamic> reward) {
    int requiredLevel = reward['approval_level'] ?? 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Approval Progress:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        for (int level = 1; level <= 3; level++) ...[
          if (level <= requiredLevel) ...[
            Row(
              children: [
                Icon(
                  _getApprovalIcon(reward['level${level}_status']),
                  color: _getApprovalColor(reward['level${level}_status']),
                ),
                SizedBox(width: 10),
                Text('Level $level: ${reward['level${level}_status'] ?? 'pending'}'),
              ],
            ),
            if (reward['level${level}_comment'] != null) ...[
              Padding(
                padding: EdgeInsets.only(left: 34),
                child: Text(
                  'Comment: ${reward['level${level}_comment']}',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ),
            ],
            SizedBox(height: 5),
          ],
        ],
      ],
    );
  }
  
  IconData _getApprovalIcon(String? status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
  
  Color _getApprovalColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
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
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}