import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import '../models/models.dart';


class EmployeeManagementPage extends StatefulWidget {
  @override
  _EmployeeManagementPageState createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  List<Employee> _employees = [];
  List<User> _managers = [];
  List<Map<String, dynamic>> _employeesWithRewardCount = [];
  bool _isLoading = true;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();


  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final db = await DatabaseHelper().database;
    int currentYear = DateTime.now().year;
    
    // Load employees with current year reward count
    final employeeData = await db.rawQuery('''
      SELECT e.*, 
             COUNT(CASE WHEN r.status = 'approved' 
                        AND strftime('%Y', r.submitted_at) = ? 
                   THEN 1 END) as current_year_rewards
      FROM employees e
      LEFT JOIN rewards r ON e.id = r.employee_id 
      GROUP BY e.id, e.employee_id, e.full_name, e.department, e.position, e.email, e.manager_id
      ORDER BY e.full_name
    ''', [currentYear.toString()]);
    
    _employeesWithRewardCount = employeeData;
    _employees = employeeData.map((e) => Employee.fromMap(e)).toList();
    
    // Load ALL users as potential managers (not just manager/admin roles)
    final managerData = await db.query('users', orderBy: 'full_name');
    _managers = managerData.map((u) => User.fromMap(u)).toList();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _uploadExcelFile() async {
    try {
      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        // Get the first sheet
        var sheet = excel.tables.keys.first;
        var rows = excel.tables[sheet]!.rows;

        if (rows.isEmpty || rows.length < 2) {
          throw Exception('Excel file is empty or has no data rows');
        }

        // Get header row
        List<String> headers = rows[0].map((cell) => 
          cell?.value?.toString() ?? ''
        ).toList();

        // Parse headers and map columns
        Map<String, int> columnMapping = _mapColumns(rows[0]);
        
        // Show column mapping dialog for user to confirm/adjust
        _showColumnMappingDialog(headers, columnMapping, rows);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to read Excel file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showColumnMappingDialog(
    List<String> headers, 
    Map<String, int> autoMapping,
    List<List<Data?>> rows
  ) async {
    Map<String, String?> selectedMapping = {
      'employeeId': null,
      'fullName': null,
      'department': null,
      'position': null,
      'email': null,
      'manager_id': null,
    };

    // Pre-fill with auto-detected mappings
    autoMapping.forEach((key, index) {
      if (index < headers.length) {
        selectedMapping[key] = headers[index];
      }
    });

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Map Excel Columns'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please map your Excel columns to the required fields:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    _buildMappingDropdown(
                      'Employee ID *',
                      selectedMapping['employeeId'],
                      headers,
                      (value) => setState(() => selectedMapping['employeeId'] = value),
                    ),
                    SizedBox(height: 15),
                    _buildMappingDropdown(
                      'Full Name *',
                      selectedMapping['fullName'],
                      headers,
                      (value) => setState(() => selectedMapping['fullName'] = value),
                    ),
                    SizedBox(height: 15),
                    _buildMappingDropdown(
                      'Department *',
                      selectedMapping['department'],
                      headers,
                      (value) => setState(() => selectedMapping['department'] = value),
                    ),
                    SizedBox(height: 15),
                    _buildMappingDropdown(
                      'Position (Optional)',
                      selectedMapping['position'],
                      headers,
                      (value) => setState(() => selectedMapping['position'] = value),
                    ),
                    SizedBox(height: 15),
                    _buildMappingDropdown(
                      'Email (Optional)',
                      selectedMapping['email'],
                      headers,
                      (value) => setState(() => selectedMapping['email'] = value),
                    ),
                    SizedBox(height: 15),
                    _buildMappingDropdown(
                      'Manager ID (Optional)',
                      selectedMapping['manager_id'],
                      headers,
                      (value) => setState(() => selectedMapping['manager_id'] = value),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Manager ID should match the User ID from the users table',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '* Required fields',
                      style: TextStyle(fontSize: 12, color: Colors.red),
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
                onPressed: () {
                  // Validate required fields
                  if (selectedMapping['employeeId'] == null ||
                      selectedMapping['fullName'] == null ||
                      selectedMapping['department'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please map all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create final column mapping
                  Map<String, int> finalMapping = {};
                  selectedMapping.forEach((key, headerName) {
                    if (headerName != null) {
                      int index = headers.indexOf(headerName);
                      if (index != -1) {
                        finalMapping[key] = index;
                      }
                    }
                  });

                  Navigator.pop(context);
                  _showImportPreviewDialog(rows, finalMapping);
                },
                child: Text('Continue'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMappingDropdown(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            hintText: 'Select column',
          ),
          items: [
            DropdownMenuItem(value: null, child: Text('-- None --')),
            ...options.where((h) => h.isNotEmpty).map((header) {
              return DropdownMenuItem(
                value: header,
                child: Text(header),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

Map<String, int> _mapColumns(List<Data?> headerRow) {
  Map<String, int> mapping = {};
  
  for (int i = 0; i < headerRow.length; i++) {
    String header = headerRow[i]?.value?.toString().toLowerCase().trim() ?? '';
    
    // Remove spaces and underscores for better matching
    String normalizedHeader = header.replaceAll(' ', '').replaceAll('_', '');
    
    // Map various possible header names
    if (header.contains('employee') && header.contains('id') || 
        header == 'empid' || header == 'emp_id' || header == 'id' ||
        normalizedHeader == 'employeeid' || normalizedHeader == 'empid') {
      mapping['employeeId'] = i;
    } 
    else if (header.contains('full') && header.contains('name') ||
             header.contains('employee') && header.contains('name') ||
             header == 'name' || header == 'fullname' ||
             normalizedHeader == 'fullname' || normalizedHeader == 'employeename') {
      mapping['fullName'] = i;
    } 
    else if (header.contains('department') || header == 'dept' ||
             normalizedHeader == 'department' || normalizedHeader == 'dept') {
      mapping['department'] = i;
    } 
    else if (header.contains('position') || header.contains('designation') ||
             header == 'role' || header == 'title' ||
             normalizedHeader == 'position' || normalizedHeader == 'designation') {
      mapping['position'] = i;
    } 
    else if (header.contains('email') || header.contains('mail') ||
             normalizedHeader == 'email' || normalizedHeader == 'emailid') {
      mapping['email'] = i;
    } 
    else if ((header.contains('manager') && header.contains('id')) ||
             header == 'manager_id' || header == 'managerid' ||
             normalizedHeader == 'managerid' || normalizedHeader == 'manageruserid' ||
             header == 'manager id' || header == 'manager user id') {
      mapping['manager_id'] = i;
    }
  }
  
  return mapping;
}

  Future<void> _showImportPreviewDialog(List<List<Data?>> rows, Map<String, int> columnMapping) async {
    // Skip header row and get data rows
    List<Map<String, String>> previewData = [];
    
    for (int i = 1; i < rows.length && i < 11; i++) {
      var row = rows[i];
      previewData.add({
        'employeeId': row[columnMapping['employeeId']!]?.value?.toString() ?? '',
        'fullName': row[columnMapping['fullName']!]?.value?.toString() ?? '',
        'department': row[columnMapping['department']!]?.value?.toString() ?? '',
        'position': columnMapping.containsKey('position') 
            ? (row[columnMapping['position']!]?.value?.toString() ?? '')
            : '',
        'email': columnMapping.containsKey('email')
            ? (row[columnMapping['email']!]?.value?.toString() ?? '')
            : '',
        'manager_id': columnMapping.containsKey('manager_id')
            ? (row[columnMapping['manager_id']!]?.value?.toString() ?? '')
            : ''
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Preview (First 10 rows)'),
        content: SizedBox(
          width: 700,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview of data to be imported:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Employee ID')),
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Position')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Manager ID')),
                      ],
                      rows: previewData.map((data) {
                        return DataRow(cells: [
                          DataCell(Text(data['employeeId']!)),
                          DataCell(Text(data['fullName']!)),
                          DataCell(Text(data['department']!)),
                          DataCell(Text(data['position']!)),
                          DataCell(Text(data['email']!)),
                          DataCell(Text(data['manager_id']!.isEmpty ? 'N/A' : data['manager_id']!)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Total rows to import: ${rows.length - 1}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _importEmployeesFromExcel(rows, columnMapping);
            },
            child: Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importEmployeesFromExcel(List<List<Data?>> rows, Map<String, int> columnMapping) async {
    final db = await DatabaseHelper().database;
    int successCount = 0;
    int failCount = 0;
    int duplicateCount = 0;
    List<String> errors = [];

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Importing employees...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        try {
          var row = rows[i];
          
          String employeeId = row[columnMapping['employeeId']!]?.value?.toString().trim() ?? '';
          String fullName = row[columnMapping['fullName']!]?.value?.toString().trim() ?? '';
          String department = row[columnMapping['department']!]?.value?.toString().trim() ?? '';
          String position = columnMapping.containsKey('position')
              ? (row[columnMapping['position']!]?.value?.toString().trim() ?? '')
              : '';
          String email = columnMapping.containsKey('email')
              ? (row[columnMapping['email']!]?.value?.toString().trim() ?? '')
              : '';
          String managerIdStr = columnMapping.containsKey('manager_id')
              ? (row[columnMapping['manager_id']!]?.value?.toString().trim() ?? '')
              : '';

          if (employeeId.isEmpty || fullName.isEmpty || department.isEmpty) {
            errors.add('Row ${i + 1}: Missing required fields (ID, Name, or Department)');
            failCount++;
            continue;
          }

          // Check if employee ID already exists in database
          final existingEmployee = await db.query(
            'employees',
            where: 'employee_id = ?',
            whereArgs: [employeeId],
          );

          if (existingEmployee.isNotEmpty) {
            // Employee ID already exists - REJECT IT
            errors.add('Row ${i + 1}: Employee ID "$employeeId" already exists - skipped');
            duplicateCount++;
            continue;
          }

          // Parse manager_id (convert to int if provided)
          int? username;
          if (managerIdStr.isNotEmpty) {
            try {
              username = int.parse(managerIdStr);
              
              // Verify that manager_id exists in users table
              final managerExists = await db.query(
                'users',
                where: 'id = ?',
                whereArgs: [username],
              );
              
              if (managerExists.isEmpty) {
                errors.add('Row ${i + 1}: Manager ID $username does not exist in users table - manager set to null');
                username = null;
              }
            } catch (e) {
              errors.add('Row ${i + 1}: Invalid manager ID "$managerIdStr" - must be a number');
              username = null;
            }
          }

          // Employee ID is unique - INSERT new employee
          Map<String, dynamic> employeeData = {
            'employee_id': employeeId,
            'full_name': fullName,
            'department': department,
            'position': position.isEmpty ? null : position,
            'email': email.isEmpty ? null : email,
            'manager_id': username,
          };

          await db.insert('employees', employeeData);
          successCount++;
          
        } catch (e) {
          errors.add('Row ${i + 1}: ${e.toString()}');
          failCount++;
        }
      }

      Navigator.pop(context); // Close loading dialog

      // Show result dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Import Complete'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✓ New employees added: $successCount', 
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text('⊘ Duplicate employee IDs rejected: $duplicateCount',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text('✗ Failed: $failCount',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                if (errors.isNotEmpty) ...[
                  SizedBox(height: 15),
                  Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        errors.join('\n'),
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );

      _loadData(); // Reload data
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.toString()}'),
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
                'Employee Management',
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
                      hintText: 'Search by ID, name or department...',
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
                onPressed: () => _showEmployeeDialog(),
                icon: Icon(Icons.add),
                label: Text('Add Employee'),
              ),
              SizedBox(width: 10),
               ElevatedButton.icon(
                onPressed: _uploadExcelFile,
                icon: Icon(Icons.upload_file),
                label: Text('Upload Excel'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Employee ID')),
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Position')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Rewards Count')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _employeesWithRewardCount.map((employeeData) {
                        final employee = Employee.fromMap(employeeData);
                        int currentYearRewards = employeeData['current_year_rewards'] ?? 0;
                        int currentYear = DateTime.now().year;
                        
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (currentYearRewards >= 2) {
                                return Colors.red.shade50;
                              }
                              return null;
                            },
                          ),
                          cells: [
                            DataCell(Text(employee.employeeId)),
                            DataCell(Text(employee.fullName)),
                            DataCell(Text(employee.department)),
                            DataCell(Text(employee.position ?? '')),
                            DataCell(Text(employee.email ?? '')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('$currentYearRewards/2 ($currentYear)'),
                                  if (currentYearRewards >= 2) ...[
                                    SizedBox(width: 5),
                                    Icon(Icons.warning, color: Colors.red, size: 16),
                                  ],
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _showEmployeeDialog(employee: employee),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEmployee(employee),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showEmployeeDialog({Employee? employee}) async {
    final formKey = GlobalKey<FormState>();
    final employeeIdController = TextEditingController(text: employee?.employeeId ?? '');
    final fullNameController = TextEditingController(text: employee?.fullName ?? '');
    final departmentController = TextEditingController(text: employee?.department ?? '');
    final positionController = TextEditingController(text: employee?.position ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    User? selectedManager;
    
    if (employee?.managerId != null) {
      try {
        selectedManager = _managers.firstWhere((m) => m.id == employee!.managerId);
      } catch (e) {
        selectedManager = _managers.isNotEmpty ? _managers.first : null;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee == null ? 'Add Employee' : 'Edit Employee'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: employeeIdController,
                  decoration: InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: departmentController,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: positionController,
                  decoration: InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<User>(
                  value: selectedManager,
                  decoration: InputDecoration(
                    labelText: 'Manager',
                    border: OutlineInputBorder(), 
                  ),
                  items: _managers.map((manager) {
                    return DropdownMenuItem(
                      value: manager,
                      child: Text(manager.username),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedManager = value;
                  },
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
                await _saveEmployee(
                  employee,
                  employeeIdController.text,
                  fullNameController.text,
                  departmentController.text,
                  positionController.text,
                  emailController.text,
                  selectedManager?.id,
                );
                Navigator.pop(context);
              }
            },
            child: Text(employee == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveEmployee(Employee? existingEmployee, String employeeId,
      String fullName, String department, String position, String email, int? managerId) async {
    final db = await DatabaseHelper().database;
    
    try {
      Map<String, dynamic> employeeData = {
        'employee_id': employeeId,
        'full_name': fullName,
        'department': department,
        'position': position.isEmpty ? null : position,
        'email': email.isEmpty ? null : email,
        'manager_id': managerId,
      };
      
      if (existingEmployee == null) {
        await db.insert('employees', employeeData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee added successfully')),
        );
      } else {
        await db.update(
          'employees',
          employeeData,
          where: 'id = ?',
          whereArgs: [existingEmployee.id],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee updated successfully')),
        );
      }
      
      _loadData();
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
  
  Future<void> _deleteEmployee(Employee employee) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final db = await DatabaseHelper().database;
                await db.delete('employees', where: 'id = ?', whereArgs: [employee.id]);
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Employee deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete employee: ${e.toString()}'),
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