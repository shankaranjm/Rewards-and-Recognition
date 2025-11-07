import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import 'package:rewards_recognition_app/screens/management_categories.dart';
import 'package:rewards_recognition_app/screens/settings.dart';
import '../models/models.dart';
import 'login_screen.dart';
import 'submit_reward_screen.dart';
import 'approvals_screen.dart';
import 'tracking_screen.dart';
import 'reports_screen.dart';
import 'employee_management_screen.dart';
import 'manage_users_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  final ValueChanged<bool> onThemeChanged;

  DashboardScreen({required this.user, required this.onThemeChanged});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<NavigationRailDestination> get _getDestinations {
    List<NavigationRailDestination> destinations = [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.add_circle),
        label: Text('Submit Reward'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.approval),
        label: Text('Approvals'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.history),
        label: Text('Tracking'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.analytics),
        label: Text('Reports'),
      ),
    ];

    // Add admin-specific destinations if the user is an ADMIN
    if (widget.user.role == 'ADMIN') {
      destinations.addAll([
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Employees'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.supervised_user_circle),
          label: Text('Users'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.category),
          label: Text('Categories'),
        ),
      ]);
    }
    
    // Add the Settings destination for all users
    destinations.add(
      NavigationRailDestination(
        icon: Icon(Icons.settings),
        label: Text('Settings'),
      ),
    );

    return destinations;
  }

  void _navigateToSection(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark to adjust the text color
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final appBarTextColor = isDarkTheme ? Colors.white : Colors.black;

    String image;
    return Scaffold(
appBar: AppBar(
  title: Row(
    children: [
      // Visteon Logo
      Image.asset(
        'assets/images/visteon_logo.png',
        height: 100, // Adjust height as needed
        width: 150,  // Adjust width as needed
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image fails to load
          return Icon(Icons.business, size: 32, color: Colors.white);
        },
      ),
      SizedBox(width: 10),
      Expanded(
        child: Center(
          child: Text(
            'Rewards & Recognition System',
            style: TextStyle(
              fontSize: 18, // Adjust as needed
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  ),
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  elevation: 2,
  actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Chip(
              label: Text(
                "Welcome🙏🏼   " + widget.user.fullName.toUpperCase(),
                style: TextStyle(
                  color: appBarTextColor, // Use dynamic color
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color.fromARGB(0, 0, 0, 0),
              labelStyle: TextStyle(
                color: appBarTextColor, // Use dynamic color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  subtitle: Text(widget.user.fullName),
                ),
                value: 'profile',
              ),
              // The settings option is now in the sidebar, but you can keep it here for redundancy or remove it
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                ),
                value: 'about',
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout'),
                ),
                value: 'logout',
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmation();
              } else if (value == 'profile') {
                _showProfileDialog();
              } else if (value == 'about') {
                _showAboutDialog();
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            destinations: _getDestinations,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              _navigateToSection(index);
            },
            backgroundColor: Theme.of(context).cardColor,
            selectedIconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).primaryColor),
            selectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            unselectedIconTheme: Theme.of(context).iconTheme,
            unselectedLabelTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          VerticalDivider(),
          Expanded(
            child: _getSelectedPage(),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedPage() {
    // Determine the number of regular pages before the admin pages
    int regularPageCount = 5; // Dashboard, Submit, Approvals, Tracking, Reports
    
    // Adjust indices based on admin role
    if (widget.user.role == 'ADMIN') {
        switch (_selectedIndex) {
          case 0:
            return DashboardPage(
              user: widget.user,
              onNavigate: _navigateToSection,
            );
          case 1:
            return SubmitRewardPage(user: widget.user);
          case 2:
            return ApprovalsPage(user: widget.user);
          case 3:
            return TrackingPage(user: widget.user);
          case 4:
            return ReportsPage(user: widget.user);
          case 5:
            return EmployeeManagementPage();
          case 6:
            return ManageUsersPage();
          case 7:
            return ManageCategoriesPage();
          case 8:
            return SettingsScreen(onThemeChanged: widget.onThemeChanged);
          default:
            return DashboardPage(user: widget.user, onNavigate: _navigateToSection);
        }
    } else {
        switch (_selectedIndex) {
          case 0:
            return DashboardPage(
              user: widget.user,
              onNavigate: _navigateToSection,
            );
          case 1:
            return SubmitRewardPage(user: widget.user);
          case 2:
            return ApprovalsPage(user: widget.user);
          case 3:
            return TrackingPage(user: widget.user);
          case 4:
            return ReportsPage(user: widget.user);
          case 5: // Settings for non-admin user
            return SettingsScreen(onThemeChanged: widget.onThemeChanged);
          default:
            return DashboardPage(user: widget.user, onNavigate: _navigateToSection);
        }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen(onThemeChanged: widget.onThemeChanged)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 10),
            Text('User Profile'),
          ],
        ),
        content: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.user.fullName.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                SizedBox(height: 15),
                _buildProfileRow('Username', widget.user.username),
                _buildProfileRow('Full Name', widget.user.fullName),
                _buildProfileRow('Email', widget.user.email),
                _buildProfileRow('Role', widget.user.role.toUpperCase()),
                _buildProfileRow(
                    'Department', widget.user.department ?? 'N/A'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 10),
            Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 64, color: Colors.blue),
            SizedBox(height: 15),
            Text(
              'Employee Rewards & Recognition System',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'A comprehensive system for managing employee rewards and recognition with multi-level approval workflows.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Dashboard Page Widget
// Dashboard Page Widget
class DashboardPage extends StatefulWidget {
  final User user;
  final Function(int) onNavigate;

  DashboardPage({required this.user, required this.onNavigate});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

Future<void> _loadStats() async {
  try {
    final db = await DatabaseHelper().database;
    int currentYear = DateTime.now().year;

    // Clean up orphaned data first
    await DatabaseHelper().cleanupOrphanedRewards();

    final totalEmployees = await db.rawQuery('SELECT COUNT(*) as count FROM employees');
    
    // Use INNER JOIN to only count rewards with valid employees
    final totalRewards = await db.rawQuery('''
      SELECT COUNT(*) as count FROM rewards r 
      INNER JOIN employees e ON r.employee_id = e.id
    ''');
    
    final currentYearRewards = await db.rawQuery('''
      SELECT COUNT(*) as count FROM rewards r 
      INNER JOIN employees e ON r.employee_id = e.id
      WHERE strftime('%Y', r.submitted_at) = ?
    ''', [currentYear.toString()]);
    
    final pendingApprovals = await db.rawQuery('''
      SELECT COUNT(*) as count FROM rewards r 
      INNER JOIN employees e ON r.employee_id = e.id
      WHERE r.status = ? AND strftime('%Y', r.submitted_at) = ?
    ''', ['pending', currentYear.toString()]);
    
    final approvedRewards = await db.rawQuery('''
      SELECT COUNT(*) as count FROM rewards r 
      INNER JOIN employees e ON r.employee_id = e.id
      WHERE r.status = ?
    ''', ['approved']);
    
    final currentYearApproved = await db.rawQuery('''
      SELECT COUNT(*) as count FROM rewards r 
      INNER JOIN employees e ON r.employee_id = e.id
      WHERE r.status = ? AND strftime('%Y', r.submitted_at) = ?
    ''', ['approved', currentYear.toString()]);

    final employeesAtLimitResult = await db.rawQuery('''
      SELECT r.employee_id, COUNT(*) as reward_count
      FROM rewards r
      INNER JOIN employees e ON r.employee_id = e.id
      WHERE r.status = 'approved'
      AND strftime('%Y', r.submitted_at) = ?
      GROUP BY r.employee_id
      HAVING COUNT(*) >= 2
    ''', [currentYear.toString()]);

    final currentYearValue = await db.rawQuery('''
      SELECT COALESCE(SUM(rc.monetary_value), 0) as total_value
      FROM rewards r
      INNER JOIN employees e ON r.employee_id = e.id
      JOIN reward_categories rc ON r.category_id = rc.id
      WHERE r.status = 'approved'
      AND strftime('%Y', r.submitted_at) = ?
    ''', [currentYear.toString()]);

    if (mounted) {
      setState(() {
        dynamic totalValue = currentYearValue.first['total_value'];
        double yearValue = 0.0;

        if (totalValue != null) {
          if (totalValue is int) {
            yearValue = totalValue.toDouble();
          } else if (totalValue is double) {
            yearValue = totalValue;
          } else if (totalValue is String) {
            yearValue = double.tryParse(totalValue) ?? 0.0;
          }
        }

        _stats = {
          'totalEmployees': totalEmployees.first['count'] as int,
          'totalRewards': totalRewards.first['count'] as int,
          'currentYearRewards': currentYearRewards.first['count'] as int,
          'pendingApprovals': pendingApprovals.first['count'] as int,
          'approvedRewards': approvedRewards.first['count'] as int,
          'currentYearApproved': currentYearApproved.first['count'] as int,
          'employeesAtLimit': employeesAtLimitResult.length,
          'currentYearValue': yearValue.toInt(),
          'currentYear': currentYear,
        };
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load stats: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Dynamic colors for the theme
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final accentColor1 = isDarkTheme ? Colors.green.shade900 : Colors.green.shade50;
    final accentColor2 = isDarkTheme ? Colors.red.shade900 : Colors.red.shade50;
    final statCardColor = isDarkTheme ? Colors.blueGrey.shade800 : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isCompact = constraints.maxWidth < 800 || constraints.maxHeight < 600;
        int crossAxisCount = isCompact ? 2 : 4;
        double childAspectRatio = isCompact ? 1.1 : 1.3;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, // Use theme color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor, // Use theme color
                      child: Text(
                        widget.user.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${widget.user.fullName}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Role: ${widget.user.role.toUpperCase()} | ${widget.user.department ?? 'N/A'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: accentColor1, // Use dynamic color
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              '₹${(_stats['currentYearValue'] ?? 0).toString()}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              '${_stats['currentYear']} Total Value',
                              style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: accentColor2, // Use dynamic color
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              '${_stats['employeesAtLimit'] ?? 0}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            Text(
                              'At 2/${_stats['currentYear']} Limit',
                              style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Statistics Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 12),
              SizedBox(
                height: isCompact ? 240 : 200,
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      'Total Employees',
                      _stats['totalEmployees']?.toString() ?? '0',
                      Icons.people,
                      Colors.blue,
                      statCardColor,
                    ),
                    _buildStatCard(
                      '${_stats['currentYear']} Rewards',
                      _stats['currentYearRewards']?.toString() ?? '0',
                      Icons.star,
                      Colors.orange,
                      statCardColor,
                    ),
                    _buildStatCard(
                      'Pending ${_stats['currentYear']}',
                      _stats['pendingApprovals']?.toString() ?? '0',
                      Icons.pending,
                      Colors.amber,
                      statCardColor,
                    ),
                    _buildStatCard(
                      'Approved ${_stats['currentYear']}',
                      _stats['currentYearApproved']?.toString() ?? '0',
                      Icons.check_circle,
                      Colors.green,
                      statCardColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 12),
              _buildQuickActionsGrid(isCompact),
              SizedBox(height: 24),
              Text(
                'System Status',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 12),
              Card(
                color: Theme.of(context).cardColor, // Use theme color
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('System Operational'),
                        subtitle: Text('All services running normally'),
                        dense: true,
                      ),
                      if (_stats['pendingApprovals']! > 0)
                        ListTile(
                          leading: Icon(Icons.notification_important, color: Colors.orange),
                          title: Text('${_stats['pendingApprovals']} Pending Approvals'),
                          subtitle: Text('Rewards waiting for your review in ${_stats['currentYear']}'),
                          dense: true,
                        ),
                      if (_stats['employeesAtLimit']! > 0)
                        ListTile(
                          leading: Icon(Icons.warning, color: Colors.red),
                          title: Text('${_stats['employeesAtLimit']} Employees at Limit'),
                          subtitle: Text('Employees who have received 2 rewards in ${_stats['currentYear']}'),
                          dense: true,
                        ),
                      ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.blue),
                        title: Text('Calendar Year: ${_stats['currentYear']}'),
                        subtitle: Text('Reward limits reset every January 1st'),
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, Color cardColor) {
    return Card(
      elevation: 2,
      color: cardColor, // Use dynamic color
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(bool isCompact) {
    List<Map<String, dynamic>> quickActions = [
      {
        'title': 'Submit Reward',
        'icon': Icons.add_circle,
        'color': Colors.green,
        'index': 1,
      },
      {
        'title': 'Approvals',
        'icon': Icons.approval,
        'color': Colors.orange,
        'index': 2,
      },
      {
        'title': 'Tracking',
        'icon': Icons.history,
        'color': Colors.blue,
        'index': 3,
      },
      {
        'title': 'Reports',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'index': 4,
      },
    ];

    if (widget.user.role == 'ADMIN') {
      quickActions.addAll([
        {
          'title': 'Employees',
          'icon': Icons.people,
          'color': Colors.teal,
          'index': 5,
        },
        {
          'title': 'Users',
          'icon': Icons.supervised_user_circle,
          'color': Colors.brown,
          'index': 6,
        },
        {
          'title': 'Categories',
          'icon': Icons.category,
          'color': Colors.indigo,
          'index': 7,
        },
      ]);
    }

    int crossAxisCount = isCompact ? 2 : 4;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isCompact ? 1.2 : 1.4,
      children: quickActions.map((action) {
        return GestureDetector(
          onTap: () => widget.onNavigate(action['index']),
          child: Card(
            elevation: 2,
            color: Theme.of(context).cardColor, // Use theme color
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey, width: 0.2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action['icon'], size: 36, color: action['color']),
                  SizedBox(height: 12),
                  Text(
                    action['title'],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
