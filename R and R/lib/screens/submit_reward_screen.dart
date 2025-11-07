import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import 'package:rewards_recognition_app/screens/award_rules.dart';
import '../models/models.dart';

class SubmitRewardPage extends StatefulWidget {
  final User user;

  SubmitRewardPage({required this.user});

  @override
  _SubmitRewardPageState createState() => _SubmitRewardPageState();
}

class _SubmitRewardPageState extends State<SubmitRewardPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _extraMilesController = TextEditingController();

  Employee? _selectedEmployee;
  RewardCategory? _selectedCategory;
  List<Employee> _employees = [];
  List<RewardCategory> _categories = [];
  bool _isLoading = false;

  String? _savingsPotential;
  String? _intangibleBenefit;
  String? _feasibleToImplement;
  String? _investmentRequired;
  String? _creativity;
  String? _typeOfImplementation;

  int _totalScore = 0;
  String _recommendedReward = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _extraMilesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = await DatabaseHelper().database;

    final employeeData = await db.query('employees');
    _employees = employeeData.map((e) => Employee.fromMap(e)).toList();

    final categoryData = await db.query('reward_categories', orderBy: 'min_score DESC');
    _categories = categoryData.map((c) => RewardCategory.fromMap(c)).toList();

    setState(() {});
  }

  void _resetForm() {
    _reasonController.clear();
    _extraMilesController.clear();
    setState(() {
      _selectedEmployee = null;
      _selectedCategory = null;
      _savingsPotential = null;
      _intangibleBenefit = null;
      _feasibleToImplement = null;
      _investmentRequired = null;
      _creativity = null;
      _typeOfImplementation = null;
      _totalScore = 0;
      _recommendedReward = '';
    });
  }

  void _calculateScore() {
    int score = 0;

    if (_savingsPotential == '>10 Lakhs') score += 45;
    else if (_savingsPotential == '5-10 Lakhs') score += 42;
    else if (_savingsPotential == '2-5 Lakhs') score += 40;
    else if (_savingsPotential == '1-5 Lakhs') score += 38;
    else if (_savingsPotential == '0.2-0.5 Lakh') score += 35;

    if (_intangibleBenefit == 'Very High') score += 25;
    else if (_intangibleBenefit == 'High') score += 22;
    else if (_intangibleBenefit == 'Moderate') score += 20;
    else if (_intangibleBenefit == 'Low') score += 18;
    else if (_intangibleBenefit == 'Very Low') score += 15;

    if (_feasibleToImplement == 'Very Difficult') score += 10;
    else if (_feasibleToImplement == 'Difficult') score += 9;
    else if (_feasibleToImplement == 'Moderate') score += 7;
    else if (_feasibleToImplement == 'Easy') score += 6;
    else if (_feasibleToImplement == 'Very Easy') score += 5;

    if (_investmentRequired == '0% - 5%') score += 10;
    else if (_investmentRequired == '5% - 10%') score += 9;
    else if (_investmentRequired == '10% - 20%') score += 7;
    else if (_investmentRequired == '20% - 30%') score += 6;
    else if (_investmentRequired == '30% - 50%') score += 5;

    if (_creativity == '100% New') score += 5;
    else if (_creativity == 'Modified') score += 4;
    else if (_creativity == 'Moderated') score += 3;
    else if (_creativity == 'Available') score += 2;

    if (_typeOfImplementation == 'All Dept.') score += 5;
    else if (_typeOfImplementation == '> 1 Dept') score += 4;
    else if (_typeOfImplementation == 'One Dept') score += 3;

    setState(() {
      _totalScore = score;
      _autoSelectCategoryByScore();
    });
  }

  // ✅ Automatically select category based on score from database
  void _autoSelectCategoryByScore() {
    if (_categories.isEmpty) return;

    // Find the category where score falls within min_score and max_score
    RewardCategory? matchedCategory;
    
    for (var category in _categories) {
      int minScore = category.minScore ?? 0;
      int maxScore = category.maxScore ?? 100;
      
      if (_totalScore >= minScore && _totalScore <= maxScore) {
        matchedCategory = category;
        break;
      }
    }

    setState(() {
      _selectedCategory = matchedCategory;
      _recommendedReward = matchedCategory?.name ?? 'No Match';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              // Employee Section
              _buildModernSectionHeader(
                'Employee Information',
                Icons.person_outline,
                Colors.blue.shade700,
              ),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Autocomplete<Employee>(
                        initialValue: _selectedEmployee != null 
                            ? TextEditingValue(text: _selectedEmployee!.employeeId)
                            : null,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _employees;
                          }
                          return _employees.where((employee) {
                            final searchText = textEditingValue.text.toLowerCase();
                            return employee.employeeId.toLowerCase().contains(searchText) ||
                                   employee.fullName.toLowerCase().contains(searchText);
                          });
                        },
                        displayStringForOption: (Employee employee) => employee.employeeId,
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Select or Type Employee',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select or enter an employee';
                              }
                              final exists = _employees.any((emp) => 
                                  emp.employeeId.toLowerCase() == value.toLowerCase());
                              if (!exists) {
                                return 'Invalid employee ID';
                              }
                              return null;
                            },
                          );
                        },
                        onSelected: (Employee employee) {
                          setState(() => _selectedEmployee = employee);
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: Container(
                                width: 300,
                                constraints: BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final employee = options.elementAt(index);
                                    return ListTile(
                                      title: Text(employee.employeeId),
                                      subtitle: Text(employee.fullName),
                                      onTap: () => onSelected(employee),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (_selectedEmployee != null) ...[
                    SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Row(
                          children: [
                            Icon(Icons.badge, size: 20, color: Colors.blue.shade700),
                            SizedBox(width: 8),
                            Text(
                              _selectedEmployee!.fullName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Row(
                          children: [
                            Icon(Icons.business, size: 20, color: Colors.blue.shade700),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedEmployee!.department,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 32),

              // Purpose Section
              _buildModernSectionHeader(
                'R&R Purpose',
                Icons.description_outlined,
                Colors.green.shade700,
              ),
              SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason for Recognition *',
                    hintText: 'Describe the achievement or contribution in detail...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.edit_note, color: Colors.green.shade700),
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a reason for recognition';
                    }
                    if (value.trim().length < 20) {
                      return 'Please provide at least 20 characters (current: ${value.trim().length})';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 32),

              // Evaluation Section
              _buildModernSectionHeader(
                'Evaluation Criteria',
                Icons.assessment_outlined,
                Colors.purple.shade700,
              ),
              SizedBox(height: 8),
              Text(
                'Evaluate the following criteria to calculate the reward score',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 16),

              _buildModernEvaluationCard(
                number: '1',
                label: 'Savings Potential per Annum',
                subtitle: 'Expected annual cost savings in INR',
                icon: Icons.savings_outlined,
                color: Colors.green,
                value: _savingsPotential,
                items: ['>10 Lakhs', '5-10 Lakhs', '2-5 Lakhs', '1-5 Lakhs', '0.2-0.5 Lakh'],
                onChanged: (val) {
                  setState(() => _savingsPotential = val);
                  _calculateScore();
                },
                maxScore: 45,
              ),

              _buildModernEvaluationCard(
                number: '2',
                label: 'Intangible Benefit',
                subtitle: 'Non-monetary impact & value',
                icon: Icons.lightbulb_outline,
                color: Colors.amber,
                value: _intangibleBenefit,
                items: ['Very High', 'High', 'Moderate', 'Low', 'Very Low'],
                onChanged: (val) {
                  setState(() => _intangibleBenefit = val);
                  _calculateScore();
                },
                maxScore: 25,
              ),

              _buildModernEvaluationCard(
                number: '3',
                label: 'Feasibility to Implement',
                subtitle: 'Ease of execution & deployment',
                icon: Icons.construction_outlined,
                color: Colors.blue,
                value: _feasibleToImplement,
                items: ['Very Difficult', 'Difficult', 'Moderate', 'Easy', 'Very Easy'],
                onChanged: (val) {
                  setState(() => _feasibleToImplement = val);
                  _calculateScore();
                },
                maxScore: 10,
              ),

              _buildModernEvaluationCard(
                number: '4',
                label: 'Investment Required',
                subtitle: 'Percentage of expected savings',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.orange,
                value: _investmentRequired,
                items: ['0% - 5%', '5% - 10%', '10% - 20%', '20% - 30%', '30% - 50%'],
                onChanged: (val) {
                  setState(() => _investmentRequired = val);
                  _calculateScore();
                },
                maxScore: 10,
              ),

              _buildModernEvaluationCard(
                number: '5',
                label: 'Creativity & Innovation',
                subtitle: 'Originality of the solution',
                icon: Icons.auto_awesome_outlined,
                color: Colors.purple,
                value: _creativity,
                items: ['100% New', 'Modified', 'Moderated', 'Available'],
                onChanged: (val) {
                  setState(() => _creativity = val);
                  _calculateScore();
                },
                maxScore: 5,
              ),

              _buildModernEvaluationCard(
                number: '6',
                label: 'Type of Implementation',
                subtitle: 'Scope of organizational impact',
                icon: Icons.domain_outlined,
                color: Colors.teal,
                value: _typeOfImplementation,
                items: ['All Dept.', '> 1 Dept', 'One Dept'],
                onChanged: (val) {
                  setState(() => _typeOfImplementation = val);
                  _calculateScore();
                },
                maxScore: 5,
              ),

              SizedBox(height: 32),

              // Score Display
              _buildScoreDisplay(),

              if (_selectedCategory != null) ...[
                SizedBox(height: 24),
                _buildRewardCategoryCard(),
              ],

              SizedBox(height: 32),

              // Submit Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Submit for Approval',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildModernEvaluationCard({
    required String number,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required int maxScore,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? color.withOpacity(0.5) : Colors.grey.shade300,
          width: value != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Max: $maxScore',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Select option',
              prefixIcon: Icon(icon, color: color),
            ),
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (val) => val == null ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    Color cupColor = _getScoreCupColor(_totalScore);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade700,
            Colors.purple.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EVALUATION SCORE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_totalScore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          '/ 100',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cupColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cupColor, width: 2),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: cupColor,
                  size: 40,
                ),
              ),
            ],
          ),
          
          if (_recommendedReward.isNotEmpty && _recommendedReward != 'No Match') ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _getRewardColor(_recommendedReward),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recommended: ${_recommendedReward.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreCupColor(int score) {
    if (_selectedCategory != null) {
      return _getRewardColor(_selectedCategory!.name);
    }
    return Colors.white;
  }

  Widget _buildRewardCategoryCard() {
    return FutureBuilder<String>(
      future: getAwardRulesContent(),
      builder: (context, snapshot) {
        String rulesContent = snapshot.data ?? 'Loading...';
        
        return Container(
          decoration: BoxDecoration(
            color: _getRewardColor(_recommendedReward).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getRewardColor(_recommendedReward).withOpacity(0.3),
              width: 2,
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getRewardColor(_recommendedReward),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.emoji_events, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Reward',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _selectedCategory!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: _getRewardColor(_recommendedReward),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 12),
              
              // Score Range Display
              _buildInfoRow(Icons.score, 'Score Range',
                  '${_selectedCategory!.minScore ?? 0} - ${_selectedCategory!.maxScore ?? 100}'),
              SizedBox(height: 8),
              
              _buildInfoRow(Icons.description, 'Description',
                  _selectedCategory!.description ?? 'N/A'),
              SizedBox(height: 8),
              _buildInfoRow(Icons.approval, 'Approval Level',
                  'Level ${_selectedCategory!.approvalLevel}'),
              if (_selectedCategory!.monetaryValue != null) ...[
                SizedBox(height: 8),
                _buildInfoRow(Icons.currency_rupee, 'Monetary Value',
                    '₹${_selectedCategory!.monetaryValue!.toStringAsFixed(0)}'),
              ],
              
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  rulesContent,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color _getRewardColor(String reward) {
    switch (reward.toLowerCase()) {
      case 'platinum':
        return Colors.deepPurple.shade700;
      case 'gold':
        return Colors.amber.shade700;
      case 'silver':
        return Colors.grey.shade600;
      case 'certification + voucher':
        return Colors.blue.shade700;
      default:
        return Colors.green.shade700;
    }}

  Future<void> _submitReward() async {
    if (_formKey.currentState!.validate()) {
      if (_totalScore == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Please complete the evaluation scheme'),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('No category matches the score. Please check category configuration.'),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final db = await DatabaseHelper().database;
        int currentYear = DateTime.now().year;

        // Check total rewards limit
        final rewardCount = await db.rawQuery('''
          SELECT COUNT(*) as count 
          FROM rewards 
          WHERE employee_id = ? 
          AND strftime('%Y', submitted_at) = ?
          AND status IN ('pending', 'approved')
        ''', [_selectedEmployee!.id, currentYear.toString()]);
        int count = rewardCount.first['count'] as int;

        if (count >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.block, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Employee already has 2 rewards in $currentYear'),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Check category duplication
        if (_selectedCategory != null) {
          final categoryCheck = await db.rawQuery('''
            SELECT COUNT(*) as count 
            FROM rewards 
            WHERE employee_id = ? 
            AND category_id = ?
            AND strftime('%Y', submitted_at) = ?
            AND status IN ('pending', 'approved')
          ''', [_selectedEmployee!.id, _selectedCategory!.id, currentYear.toString()]);
          int categoryCount = categoryCheck.first['count'] as int;

          if (categoryCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.block, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('${_selectedCategory!.name} already awarded for this employee in $currentYear'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        // Check Level 1 approver
        final approverQuery = await db.query(
          'users',
          where: 'department = ? AND role = ?',
          whereArgs: [_selectedEmployee!.department, 'approver_level1'],
        );

        if (approverQuery.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('No Level 1 approver found for ${_selectedEmployee!.department}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        final level1ApproverId = approverQuery.first['id'];

        // Insert reward with evaluation data
        await db.insert('rewards', {
          'employee_id': _selectedEmployee!.id,
          'category_id': _selectedCategory!.id,
          'nominated_by': widget.user.id,
          'reason': _reasonController.text.trim(),
          'submitted_at': DateTime.now().toIso8601String(),
          'level1_approver': level1ApproverId,
          'level1_status': 'pending',
          'status': 'pending',
          'current_approval_level': 1,
          'evaluation_score': _totalScore,
          'savings_potential': _savingsPotential,
          'intangible_benefit': _intangibleBenefit,
          'feasible_to_implement': _feasibleToImplement,
          'investment_required': _investmentRequired,
          'creativity': _creativity,
          'type_of_implementation': _typeOfImplementation,
          'extra_miles': _extraMilesController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reward Submitted Successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Score: $_totalScore - $_recommendedReward',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 4),
          ),
        );

        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Failed to submit: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }
}