import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import '../models/models.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  final User user;
  
  ReportsPage({required this.user});
  
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;
  
  // Filter variables
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedDepartment;
  List<String> _departments = [];
  
  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadReportData();
  }
  
  Future<void> _loadDepartments() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
      SELECT DISTINCT department 
      FROM employees 
      WHERE department IS NOT NULL 
      ORDER BY department
    ''');
    
    setState(() {
      _departments = result.map((e) => e['department'] as String).toList();
    });
  }
  
  Future<void> _loadReportData() async {
    final db = await DatabaseHelper().database;
    
    // Department-wise rewards
    final deptRewards = await db.rawQuery('''
      SELECT e.department, COUNT(r.id) as reward_count,
             COALESCE(SUM(rc.monetary_value), 0) as total_value
      FROM employees e
      LEFT JOIN rewards r ON e.id = r.employee_id AND r.status = 'approved'
      LEFT JOIN reward_categories rc ON r.category_id = rc.id
      GROUP BY e.department
      ORDER BY reward_count DESC
    ''');
    
    // Category-wise distribution
    final categoryDist = await db.rawQuery('''
      SELECT rc.name, COUNT(r.id) as count,
             COALESCE(SUM(rc.monetary_value), 0) as total_value
      FROM reward_categories rc
      LEFT JOIN rewards r ON rc.id = r.category_id AND r.status = 'approved'
      GROUP BY rc.id, rc.name
      ORDER BY count DESC
    ''');
    
    // Monthly trends (last 6 months)
    final monthlyTrends = await db.rawQuery('''
      SELECT strftime('%Y-%m', r.submitted_at) as month,
             COUNT(r.id) as submissions,
             SUM(CASE WHEN r.status = 'approved' THEN 1 ELSE 0 END) as approved
      FROM rewards r
      WHERE r.submitted_at >= date('now', '-6 months')
      GROUP BY strftime('%Y-%m', r.submitted_at)
      ORDER BY month
    ''');
    
    setState(() {
      _reportData = {
        'departmentRewards': deptRewards,
        'categoryDistribution': categoryDist,
        'monthlyTrends': monthlyTrends,
      };
      _isLoading = false;
    });
  }
  
Future<void> _downloadExcelReport() async {
  // Validate date selection
  if (_fromDate == null || _toDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please select both From and To dates'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }
  
  try {
    setState(() => _isLoading = true);
    
    final db = await DatabaseHelper().database;
    
    // Prepare date strings for query
    String fromDateStr = DateFormat('yyyy-MM-dd').format(_fromDate!);
    String toDateStr = DateFormat('yyyy-MM-dd').format(_toDate!);
    
    // Build WHERE clause and arguments
    String whereClause = "WHERE DATE(r.submitted_at) BETWEEN DATE(?) AND DATE(?)";
    List<dynamic> whereArgs = [fromDateStr, toDateStr];
    
    // Add department filter ONLY if a specific department is selected
    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      whereClause += " AND e.department = ?";
      whereArgs.add(_selectedDepartment);
    }
    
    print('=== GENERATING EXCEL REPORT ===');
    print('Date Range: $fromDateStr to $toDateStr');
    print('Department Filter: ${_selectedDepartment ?? "ALL DEPARTMENTS"}');
    print('WHERE Clause: $whereClause');
    print('Arguments: $whereArgs');
    
    // Fetch all reward records matching the filters
    final rewardData = await db.rawQuery('''
      SELECT 
        e.employee_id,
        e.full_name as employee_name,
        e.email,
        e.department,
        e.position,
        rc.name as reward_category,
        rc.monetary_value,
        r.reason as description,
        r.submitted_at,
        r.status,
        r.approved_at,
        approver1.full_name as level1_approver_name,
        approver2.full_name as level2_approver_name,
        approver3.full_name as level3_approver_name
      FROM rewards r
      INNER JOIN employees e ON r.employee_id = e.id
      INNER JOIN reward_categories rc ON r.category_id = rc.id
      LEFT JOIN users approver1 ON r.level1_approver = approver1.id
      LEFT JOIN users approver2 ON r.level2_approver = approver2.id
      LEFT JOIN users approver3 ON r.level3_approver = approver3.id
      $whereClause
      ORDER BY e.department, e.employee_id, r.submitted_at DESC
    ''', whereArgs);
    
    print('Records Found: ${rewardData.length}');
    
    // Check if any data was found
    if (rewardData.isEmpty) {
      setState(() => _isLoading = false);
      
      // Show detailed message
      String message = 'No rewards found for the selected criteria:\n\n';
      message += 'Date Range: ${DateFormat('dd-MMM-yyyy').format(_fromDate!)} to ${DateFormat('dd-MMM-yyyy').format(_toDate!)}\n';
      message += 'Department: ${_selectedDepartment ?? "All Departments"}\n\n';
      message += 'Please verify:\n';
      message += '• Rewards exist in this date range\n';
      message += '• Date range includes reward submission dates\n';
      message += '• Selected department has rewards';
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 10),
              Text('No Data Found'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    print('Creating Excel file with ${rewardData.length} records...');
    
    // Create Excel workbook
    var excel = Excel.createExcel();
    excel.delete('Sheet1');
    
    // ==================== SHEET 1: EMPLOYEE REWARDS ====================
    Sheet sheetRewards = excel['Employee Rewards'];
    
    // Define column headers
    List<String> headers = [
      'Employee ID',
      'Employee Name',
      'Email',
      'Department',
      'Position',
      'Reward Category',
      'Monetary Value (₹)',
      'Description',
      'Submitted Date',
      'Status',
      'Approved Date',
      'L1 Approver',
      'L2 Approver',
      'L3 Approver'
    ];
    
    // Add headers with styling
    for (int col = 0; col < headers.length; col++) {
      var cell = sheetRewards.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
      );
    }
    
    // Add data rows
    for (int rowIdx = 0; rowIdx < rewardData.length; rowIdx++) {
      var record = rewardData[rowIdx];
      
      // Format dates nicely
      String submittedDate = record['submitted_at']?.toString() ?? '';
      if (submittedDate.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(submittedDate);
          submittedDate = DateFormat('dd-MMM-yyyy HH:mm').format(dt);
        } catch (e) {
          // Keep original if parsing fails
        }
      }
      
      String approvedDate = record['approved_at']?.toString() ?? '';
      if (approvedDate.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(approvedDate);
          approvedDate = DateFormat('dd-MMM-yyyy HH:mm').format(dt);
        } catch (e) {
          approvedDate = '';
        }
      }
      
      // Prepare row data
      List<String> rowData = [
        record['employee_id']?.toString() ?? '',
        record['employee_name']?.toString() ?? '',
        record['email']?.toString() ?? '',
        record['department']?.toString() ?? '',
        record['position']?.toString() ?? '',
        record['reward_category']?.toString() ?? '',
        record['monetary_value']?.toString() ?? '0',
        record['description']?.toString() ?? '',
        submittedDate,
        record['status']?.toString().toUpperCase() ?? '',
        approvedDate,
        record['level1_approver_name']?.toString() ?? 'N/A',
        record['level2_approver_name']?.toString() ?? 'N/A',
        record['level3_approver_name']?.toString() ?? 'N/A',
      ];
      
      // Write data to cells
      for (int col = 0; col < rowData.length; col++) {
        var cell = sheetRewards.cell(CellIndex.indexByColumnRow(
          columnIndex: col, 
          rowIndex: rowIdx + 1
        ));
        cell.value = TextCellValue(rowData[col]);
        
        // Color code based on status
        if (col == 9) { // Status column
          String status = rowData[col].toLowerCase();
          if (status == 'approved') {
            cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.green100);
          } else if (status == 'pending') {
            cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.yellow);
          } else if (status == 'rejected') {
            cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.red100);
          }
        }
      }
    }
    
    print('Added ${rewardData.length} data rows to Employee Rewards sheet');
    
    // ==================== SHEET 2: SUMMARY ====================
    Sheet sheetSummary = excel['Summary'];
    int row = 0;
    
    // Title
    var titleCell = sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++));
    titleCell.value = TextCellValue('REWARDS REPORT SUMMARY');
    titleCell.cellStyle = CellStyle(bold: true, fontSize: 18);
    row++;
    
    // Report Parameters Section
    sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
      .value = TextCellValue('REPORT PARAMETERS');
    
    var params = [
      ['From Date:', DateFormat('dd-MMM-yyyy').format(_fromDate!)],
      ['To Date:', DateFormat('dd-MMM-yyyy').format(_toDate!)],
      ['Department:', _selectedDepartment ?? 'All Departments'],
      ['Generated On:', DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now())],
    ];
    
    for (var param in params) {
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(param[0]);
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row++))
        .value = TextCellValue(param[1]);
    }
    row++;
    
    // Calculate statistics
    int totalRewards = rewardData.length;
    int approvedCount = rewardData.where((r) => r['status']?.toString().toLowerCase() == 'approved').length;
    int pendingCount = rewardData.where((r) => r['status']?.toString().toLowerCase() == 'pending').length;
    int rejectedCount = rewardData.where((r) => r['status']?.toString().toLowerCase() == 'rejected').length;
    
    double totalValue = 0.0;
    double approvedValue = 0.0;
    
    for (var r in rewardData) {
      double value = double.tryParse(r['monetary_value']?.toString() ?? '0') ?? 0.0;
      totalValue += value;
      if (r['status']?.toString().toLowerCase() == 'approved') {
        approvedValue += value;
      }
    }
    
    // Statistics Section
    sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
      .value = TextCellValue('SUMMARY STATISTICS');
    
    var stats = [
      ['Total Rewards Submitted:', totalRewards.toString()],
      ['Approved Rewards:', '$approvedCount (${totalRewards > 0 ? (approvedCount * 100 / totalRewards).toStringAsFixed(1) : 0}%)'],
      ['Pending Rewards:', '$pendingCount (${totalRewards > 0 ? (pendingCount * 100 / totalRewards).toStringAsFixed(1) : 0}%)'],
      ['Rejected Rewards:', '$rejectedCount (${totalRewards > 0 ? (rejectedCount * 100 / totalRewards).toStringAsFixed(1) : 0}%)'],
      ['Total Monetary Value:', '₹${totalValue.toStringAsFixed(2)}'],
      ['Approved Value:', '₹${approvedValue.toStringAsFixed(2)}'],
    ];
    
    for (var stat in stats) {
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(stat[0]);
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row++))
        .value = TextCellValue(stat[1]);
    }
    row += 2;
    
    // Department-wise Breakdown
    if (_selectedDepartment == null) {
      Map<String, int> deptCount = {};
      Map<String, double> deptValue = {};
      
      for (var r in rewardData) {
        String dept = r['department']?.toString() ?? 'Unknown';
        double value = double.tryParse(r['monetary_value']?.toString() ?? '0') ?? 0.0;
        deptCount[dept] = (deptCount[dept] ?? 0) + 1;
        deptValue[dept] = (deptValue[dept] ?? 0.0) + value;
      }
      
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
        .value = TextCellValue('DEPARTMENT-WISE BREAKDOWN');
      
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Department');
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('Count');
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
        .value = TextCellValue('Total Value (₹)');
      
      deptCount.forEach((dept, count) {
        sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(dept);
        sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(count.toString());
        sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
          .value = TextCellValue('₹${deptValue[dept]?.toStringAsFixed(2)}');
      });
      row++;
    }
    
    // Category-wise Breakdown
    Map<String, int> categoryCount = {};
    Map<String, double> categoryValue = {};
    
    for (var r in rewardData) {
      String category = r['reward_category']?.toString() ?? 'Unknown';
      double value = double.tryParse(r['monetary_value']?.toString() ?? '0') ?? 0.0;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      categoryValue[category] = (categoryValue[category] ?? 0.0) + value;
    }
    
    sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row++))
      .value = TextCellValue('CATEGORY-WISE BREAKDOWN');
    
    sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      .value = TextCellValue('Reward Category');
    sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      .value = TextCellValue('Count');
    sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
      .value = TextCellValue('Total Value (₹)');
    
    categoryCount.forEach((category, count) {
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(category);
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(count.toString());
      sheetSummary.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++))
        .value = TextCellValue('₹${categoryValue[category]?.toStringAsFixed(2)}');
    });
    
    print('Summary sheet created');
    
    // ==================== SAVE FILE ====================
    var fileBytes = excel.save();
    
    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception('Failed to generate Excel file bytes');
    }
    
    print('Excel file generated: ${fileBytes.length} bytes');
    
    // Get Downloads folder path - C:\Users\<username>\Downloads
    String username = Platform.environment['USERNAME'] ?? Platform.environment['USER'] ?? 'User';
    String downloadsPath = 'C:\\Users\\$username\\Downloads';
    Directory downloadsDir = Directory(downloadsPath);
    
    // Verify directory exists, create if it doesn't
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }
    
    // Create filename
    String fileName = 'Rewards_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    String filePath = '$downloadsPath\\$fileName';
    
    // Write file
    File file = File(filePath);
    await file.writeAsBytes(fileBytes);
    
    print('File saved: $filePath');
    print('File size: ${file.lengthSync()} bytes');
    
    setState(() => _isLoading = false);
    
    // Show centered success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
                SizedBox(height: 20),
                
                // Success Title
                Text(
                  'Report Generated Successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                
                // Details
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${rewardData.length} employee rewards exported',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.insert_drive_file, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.folder_open, size: 20, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              filePath,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close),
                      label: Text('Close'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // Open file explorer to Downloads folder
                        try {
                          if (Platform.isWindows) {
                            await Process.run('explorer', ['/select,', filePath]);
                          }
                        } catch (e) {
                          print('Could not open file explorer: $e');
                        }
                      },
                      icon: Icon(Icons.folder_open),
                      label: Text('Open Folder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    
  } catch (e, stackTrace) {
    setState(() => _isLoading = false);
    print('ERROR: $e');
    print('STACK: $stackTrace');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error generating report: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }
}

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports & Analytics',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 20),
          
          // Filter Section
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Excel Report',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'From Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _fromDate != null
                                  ? DateFormat('dd-MM-yyyy').format(_fromDate!)
                                  : 'Select date',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'To Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _toDate != null
                                  ? DateFormat('dd-MM-yyyy').format(_toDate!)
                                  : 'Select date',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Department',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDepartment,
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('All Departments'),
                            ),
                            ..._departments.map((dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _downloadExcelReport,
                    icon: Icon(Icons.download),
                    label: Text('Download Excel Report'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      _buildDepartmentReport(),
                      SizedBox(height: 30),
                      _buildCategoryReport(),
                      SizedBox(height: 30),
                      _buildTrendsReport(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDepartmentReport() {
    final data = _reportData['departmentRewards'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department-wise Rewards',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 15),
            DataTable(
              columns: [
                DataColumn(label: Text('Department')),
                DataColumn(label: Text('Rewards Count')),
                DataColumn(label: Text('Total Value (₹)')),
              ],
              rows: data.map((dept) {
                return DataRow(cells: [
                  DataCell(Text(dept['department'] ?? 'Unknown')),
                  DataCell(Text(dept['reward_count'].toString())),
                  DataCell(Text('₹${dept['total_value'].toStringAsFixed(0)}')),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryReport() {
    final data = _reportData['categoryDistribution'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Distribution',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 15),
            DataTable(
              columns: [
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Count')),
                DataColumn(label: Text('Total Value (₹)')),
              ],
              rows: data.map((cat) {
                return DataRow(cells: [
                  DataCell(Text(cat['name'])),
                  DataCell(Text(cat['count'].toString())),
                  DataCell(Text('₹${cat['total_value'].toStringAsFixed(2)}')),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrendsReport() {
    final data = _reportData['monthlyTrends'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Trends',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 15),
            if (data.isEmpty)
              Text('No data available for the last 6 months')
            else
              DataTable(
                columns: [
                  DataColumn(label: Text('Month')),
                  DataColumn(label: Text('Submissions')),
                  DataColumn(label: Text('Approved')),
                  DataColumn(label: Text('Approval Rate')),
                ],
                rows: data.map((month) {
                  int submissions = month['submissions'] ?? 0;
                  int approved = month['approved'] ?? 0;
                  double rate = submissions > 0 ? (approved / submissions * 100) : 0;
                  
                  return DataRow(cells: [
                    DataCell(Text(month['month'] ?? '')),
                    DataCell(Text(submissions.toString())),
                    DataCell(Text(approved.toString())),
                    DataCell(Text('${rate.toStringAsFixed(1)}%')),
                  ]);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}