// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewards_recognition_app/screens/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required ValueChanged<bool> onThemeChanged}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state to hold the temporary theme setting
  late bool _tempIsDarkMode;

  @override
  void initState() {
    super.initState();
    // Initialize local state from the current theme provider state
    _tempIsDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider instance using Provider.of
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Appearance'),
                  Card(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dark_mode, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    'Toggle between light and dark theme',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            // The Switch now uses the local state variable
                            value: _tempIsDarkMode,
                            onChanged: (value) {
                              // Update the local state, not the provider directly
                              setState(() {
                                _tempIsDarkMode = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildSectionHeader(context, 'Actions'),
                  Card(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('About', textAlign: TextAlign.center),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 15),
                            Text(
                              'About',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // On save, update the theme provider with the local state value
                        themeProvider.toggleTheme(_tempIsDarkMode);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings saved!')),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required bool isSelected}) {
    return Container(
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          // Handle navigation here
        },
      ),
    );
  }
}