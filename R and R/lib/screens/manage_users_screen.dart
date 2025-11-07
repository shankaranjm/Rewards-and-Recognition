import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import '../models/models.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<User> _allUsers = [];
  List<User> _users = [];
  bool _isLoading = true;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _users = _allUsers;
      } else {
        _users = _allUsers.where((user) {
          final username = user.username.toLowerCase();
          final fullName = user.fullName.toLowerCase();
          final department = (user.department ?? '').toLowerCase();
          
          return username.contains(query) || 
                 fullName.contains(query) || 
                 department.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadUsers() async {
    final db = await DatabaseHelper().database;
    final userData = await db.query('users');

    setState(() {
      _allUsers = userData.map((u) => User.fromMap(u)).toList();
      _users = userData.map((u) => User.fromMap(u)).toList();
      _isLoading = false;
    });
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
                'User Management',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Spacer(),
              if (_showSearch) ...[
                Container(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search by username, name or department...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showSearch = false;
                            _searchController.clear();
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
              if (!_showSearch)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSearch = true;
                    });
                  },
                  icon: Icon(Icons.search),
                  tooltip: 'Search',
                ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showUserDialog(),
                icon: Icon(Icons.add),
                label: Text('Add User'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Username')),
                            DataColumn(label: Text('Full Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Department')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _users.map((user) {
                            return DataRow(cells: [
                              DataCell(Text(user.username)),
                              DataCell(Text(user.fullName)),
                              DataCell(Text(user.email)),
                              DataCell(
                                Chip(
                                  label: Text(user.role.toUpperCase()),
                                  backgroundColor: _getRoleColor(user.role),
                                ),
                              ),
                              DataCell(Text(user.department ?? '')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _showUserDialog(user: user),
                                    ),
                                    if (user.username != 'admin')
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteUser(user),
                                      ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color.fromARGB(255, 215, 47, 63);
      case 'manager':
        return const Color.fromARGB(255, 15, 197, 234);
      case 'approver_level1':
      case 'approver_level2':
      case 'approver_level3':
        return const Color.fromARGB(255, 16, 161, 21);
      default:
        return const Color.fromARGB(255, 213, 47, 47);
    }
  }

  Future<void> _showUserDialog({User? user}) async {
    final formKey = GlobalKey<FormState>();
    final usernameController =
        TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    final fullNameController =
        TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final departmentController =
        TextEditingController(text: user?.department ?? '');
    String selectedRole = user?.role ?? 'manager';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username[Eg:XY123 ]',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: user == null
                        ? 'Password'
                        : 'New Password (leave empty to keep current)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (user == null && (value?.isEmpty == true)) {
                      return 'Password required for new user';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'ADMIN',
                    'manager',
                    'approver_level1',
                    'approver_level2',
                    'approver_level3'
                  ]
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {
                    selectedRole = value!;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: departmentController,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _saveUser(
                  user,
                  usernameController.text,
                  passwordController.text,
                  fullNameController.text,
                  emailController.text,
                  selectedRole,
                  departmentController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text(user == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUser(User? existingUser, String username, String password,
      String fullName, String email, String role, String department) async {
    final db = await DatabaseHelper().database;

    try {
      Map<String, dynamic> userData = {
        'username': username,
        'full_name': fullName,
        'email': email,
        'role': role,
        'department': department.isEmpty ? null : department,
      };

      if (existingUser == null) {
        // New user
        userData['password'] = password;
        await db.insert('users', userData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User added successfully')),
        );
      } else {
        // Update existing user
        if (password.isNotEmpty) {
          userData['password'] = password;
        }
        await db.update('users', userData,
            where: 'id = ?', whereArgs: [existingUser.id]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully')),
        );
      }

      _loadUsers();
    } catch (e) {
  // Log detailed error to console for debugging
  print('Failed to save employee: ${e.toString()}');
  print('Stack trace: ${StackTrace.current}');
  
  // Show user-friendly message in UI
  String userMessage;
  
  if (e.toString().contains('duplicate') || 
      e.toString().contains('UNIQUE constraint failed') ||
      e.toString().contains('already exists')) {
    userMessage = 'Employee ID already exists. Please enter a different ID.';
  } else if (e.toString().contains('required')) {
    userMessage = 'Please fill in all required fields.';
  } else {
    userMessage = 'Failed to save employee. Please try again.';
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(userMessage),
      backgroundColor: Colors.red,
    ),
  );
}  
  }

  Future<void> _deleteUser(User user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final db = await DatabaseHelper().database;
                await db.delete('users', where: 'id = ?', whereArgs: [user.id]);
                Navigator.pop(context);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete user: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}