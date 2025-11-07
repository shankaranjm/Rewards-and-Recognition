// import 'package:flutter/material.dart';
// import 'package:rewards_recognition_app/database/databasehelper.dart';
// import 'package:rewards_recognition_app/screens/dashboard_screen.dart';
// import '../models/models.dart';


// class LoginScreen extends StatefulWidget {
//   final ValueChanged<bool> onThemeChanged;

//   const LoginScreen({
//     Key? key,
//     required this.onThemeChanged,
//   }) : super(key: key);

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue.shade400, Colors.blue.shade800],
//           ),
//         ),
//         child: Center(
//           child: Card(
//             margin: EdgeInsets.all(20),
//             child: Container(
//               width: 400,
//               padding: EdgeInsets.all(30),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Icon(
//                     //   Icons.star,
//                     //   size: 64,
//                     //   color: Colors.blue,
//                     // ),
//                     Image.asset(
//                 'assets/images/visteon_logo.png',
//                 height: 55, // Reduced logo height
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) {
//                   // Fallback if image fails to load
//                   return Icon(Icons.business, size: 42, color: Colors.white);
//                 },
//               ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Rewards & Recognition',
//                       style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 30),
//                     TextFormField(
//                       controller: _usernameController,
//                       decoration: InputDecoration(
//                         labelText: 'Username',
//                         prefixIcon: Icon(Icons.person),
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter username';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 20),
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: Icon(Icons.lock),
//                         border: OutlineInputBorder(),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter password';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 30),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _login,
//                         child: _isLoading
//                             ? CircularProgressIndicator()
//                             : Text('Login'),
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(vertical: 15),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
      
//       try {
//         final db = await DatabaseHelper().database;
//         final users = await db.query(
//           'users',
//           where: 'username = ? AND password = ?',
//           whereArgs: [_usernameController.text, _passwordController.text],
//         );
        
//         if (users.isNotEmpty) {
//           User user = User.fromMap(users.first);
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DashboardScreen(
//                 user: user,
//                 // Pass the theme callback to the DashboardScreen
//                 onThemeChanged: widget.onThemeChanged,
//               ),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Invalid username or password')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login failed: ${e.toString()}')),
//         );
//       }
      
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
  
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }