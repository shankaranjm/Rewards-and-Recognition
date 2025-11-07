import 'package:flutter/material.dart';
import 'package:rewards_recognition_app/database/databasehelper.dart';
import 'package:rewards_recognition_app/screens/dashboard_screen.dart';
import '../models/models.dart';

class LoginScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const LoginScreen({
    Key? key,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  late AnimationController _floatingController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late List<AnimationController> _bubbleControllers;
  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _cardController = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _bubbleControllers = List.generate(5, (index) {
      return AnimationController(
        duration: Duration(seconds: 3 + index),
        vsync: this,
      )..repeat();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _floatingController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0EA5E9),
                  Color(0xFF06B6D4),
                  Color(0xFF10B981),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated floating bubbles
                ..._buildAnimatedBubbles(),
                
                // Floating icons background
                _buildFloatingIcons(),

                // Decorative circles
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -80,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Login Card with animation
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.80, end: 1.0).animate(
                CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
                    CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
                  ),
                  child: _buildLoginCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedBubbles() {
    return List.generate(5, (index) {
      final positions = [
        (100.0, 150.0),
        (300.0, 200.0),
        (150.0, 400.0),
        (350.0, 500.0),
        (200.0, 100.0),
      ];

      return Positioned(
        top: positions[index].$1,
        left: positions[index].$2,
        child: AnimatedBuilder(
          animation: _bubbleControllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                -60 * _bubbleControllers[index].value,
              ),
              child: Opacity(
                opacity: (1 - _bubbleControllers[index].value) * 0.4,
                child: Container(
                  width: 40 - (20 * _bubbleControllers[index].value),
                  height: 40 - (20 * _bubbleControllers[index].value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 60 + (30 * _floatingController.value),
              left: 30,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  Icons.emoji_events,
                  size: 90,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 80 + (25 * _floatingController.value),
              right: 40,
              child: Opacity(
                opacity: 0.18,
                child: Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 120 + (35 * _floatingController.value),
              left: 50,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.workspace_premium,
                  size: 95,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 100 + (28 * _floatingController.value),
              right: 60,
              child: Opacity(
                opacity: 0.16,
                child: Icon(
                  Icons.card_giftcard,
                  size: 85,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoginCard() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(20),
        width: 420,
        padding: EdgeInsets.all(45),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 5,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Trophy Icon with pulse
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (0.05 * (0.5 - (_pulseController.value - 0.5).abs())),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 1200),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.5 + (value * 0.5),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF9E64), Color(0xFFFF6B6B)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFF9E64).withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
              
              // Visteon Logo
              Image.asset(
                'assets/images/visteon_logo.png',
                height: 45,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
              ),
              SizedBox(height: 16),
              
              // Animated Title
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                  ).createShader(bounds);
                },
                child: Text(
                  'Rewards & Recognition',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8),
              
              // Animated Subtitle
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      // child: Text(
                      //   'Celebrate your achievements',
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     color: Colors.grey.shade600,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ),
                  );
                },
              ),
              SizedBox(height: 35),
              
              // Username Field
              _buildAnimatedInputField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 18),
              
              // Password Field
              _buildAnimatedInputField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              
              // Login Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0EA5E9).withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _login,
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.white.withOpacity(0.3),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                prefixIcon: Icon(icon, color: Color(0xFF0EA5E9), size: 22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF0EA5E9), width: 2.5),
                ),
                filled: true,
                fillColor: Color(0xFFF0F9FF),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
              validator: validator,
            ),
          ),
        );
      },
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final db = await DatabaseHelper().database;
        final users = await db.query(
          'users',
          where: 'username = ? AND password = ?',
          whereArgs: [_usernameController.text, _passwordController.text],
        );

        if (users.isNotEmpty) {
          User user = User.fromMap(users.first);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                user: user,
                onThemeChanged: widget.onThemeChanged,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid username or password'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}