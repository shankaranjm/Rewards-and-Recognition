import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import 'package:rewards_recognition_app/screens/award_rules.dart';
import '../models/models.dart';

class ManageCategoriesPage extends StatefulWidget {
  @override
  _ManageCategoriesPageState createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  List<RewardCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = await DatabaseHelper().database;
    final categoryData = await db.query('reward_categories', orderBy: 'min_score DESC');

    setState(() {
      _categories = categoryData.map((c) => RewardCategory.fromMap(c)).toList();
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
                'Reward Categories',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(),
                icon: Icon(Icons.add),
                label: Text('Add Category'),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _displayAwardrules(),
                icon: Icon(Icons.edit),
                label: Text('Award Rules'),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Configure score ranges (0-100) for automatic category selection. Ranges can overlap - highest min_score wins.',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
         
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _getCategoryColor(category.name).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category.name).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: _getCategoryColor(category.name),
                              size: 28,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category.name),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Score: ${category.minScore ?? 0} - ${category.maxScore ?? 100}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              if (category.description != null)
                                Text(
                                  category.description!,
                                  style: TextStyle(fontSize: 14),
                                ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.approval, size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 4),
                                  Text(
                                    'Approval: Level ${category.approvalLevel}',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(width: 16),
                                  if (category.monetaryValue != null) ...[
                                    Icon(Icons.currency_rupee, size: 16, color: Colors.grey.shade600),
                                    SizedBox(width: 4),
                                    Text(
                                      '₹${category.monetaryValue!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showCategoryDialog(category: category),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(category),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'platinum':
        return Colors.deepPurple;
      case 'gold':
        return Colors.amber.shade700;
      case 'silver':
        return Colors.grey.shade600;
      case 'certificate + voucher':
      case 'bronze':
        return Colors.blue.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  Future<void> _displayAwardrules() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AwardRulesContentPage()),
    );
  }

  Future<void> _showCategoryDialog({RewardCategory? category}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    final valueController = TextEditingController(
      text: category?.monetaryValue?.toString() ?? '',
    );
    final minScoreController = TextEditingController(
      text: category?.minScore?.toString() ?? '',
    );
    final maxScoreController = TextEditingController(
      text: category?.maxScore?.toString() ?? '',
    );
    int selectedLevel = category?.approvalLevel ?? 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              category == null ? Icons.add_circle_outline : Icons.edit,
              color: Colors.blue.shade700,
            ),
            SizedBox(width: 12),
            Text(category == null ? 'Add Category' : 'Edit Category'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.score, color: Colors.amber.shade700, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Score Range Configuration',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: minScoreController,
                                decoration: InputDecoration(
                                  labelText: 'Min Score *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.arrow_downward),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty == true) return 'Required';
                                  final min = int.tryParse(value!);
                                  if (min == null || min < 0 || min > 100) {
                                    return 'Must be 0-100';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: maxScoreController,
                                decoration: InputDecoration(
                                  labelText: 'Max Score *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.arrow_upward),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty == true) return 'Required';
                                  final max = int.tryParse(value!);
                                  final min = int.tryParse(minScoreController.text);
                                  if (max == null || max < 0 || max > 100) {
                                    return 'Must be 0-100';
                                  }
                                  if (min != null && max <= min) {
                                    return 'Must be > Min';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Set any range (0-100). Overlapping ranges allowed.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: selectedLevel,
                    decoration: InputDecoration(
                      labelText: 'Approval Level Required *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.approval),
                    ),
                    items: [1, 2, 3].map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text('Level $level'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedLevel = value!;
                    },
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: 'Monetary Value (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                      hintText: 'e.g., 25000 for ₹25,000',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
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
                await _saveCategory(
                  category,
                  nameController.text,
                  descriptionController.text,
                  selectedLevel,
                  double.tryParse(valueController.text),
                  int.tryParse(minScoreController.text),
                  int.tryParse(maxScoreController.text),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: Text(
              category == null ? 'Add' : 'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory(
    RewardCategory? existingCategory,
    String name,
    String description,
    int approvalLevel,
    double? monetaryValue,
    int? minScore,
    int? maxScore,
  ) async {
    final db = await DatabaseHelper().database;

    try {
      Map<String, dynamic> categoryData = {
        'name': name,
        'description': description.isEmpty ? null : description,
        'approval_level': approvalLevel,
        'monetary_value': monetaryValue,
        'min_score': minScore,
        'max_score': maxScore,
      };

      if (existingCategory == null) {
        await db.insert('reward_categories', categoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added successfully')),
        );
      } else {
        await db.update(
          'reward_categories',
          categoryData,
          where: 'id = ?',
          whereArgs: [existingCategory.id],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated successfully')),
        );
      }

      _loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save category: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCategory(RewardCategory category) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final db = await DatabaseHelper().database;
                await db.delete(
                  'reward_categories',
                  where: 'id = ?',
                  whereArgs: [category.id],
                );
                Navigator.pop(context);
                _loadCategories();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete category: ${e.toString()}'),
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

Future<String> getAwardRulesContent() async {
  try {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'award_rules_content',
      where: 'category = ?',
      whereArgs: ['common'],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first['content_text'] as String;
    }
    return 'No award rules configured';
  } catch (e) {
    return 'Error loading award rules';
  }
}