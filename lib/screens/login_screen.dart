import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isTeacherLogin = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kNormalAnimationDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLoginType() {
    setState(() {
      _isTeacherLogin = !_isTeacherLogin;
      _errorMessage = '';
    });
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
        _isLoading = false;
      });
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.login(username, password);

    if (user == null) {
      setState(() {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
      });
      return;
    }

    if ((user.role == UserRole.teacher && !_isTeacherLogin) ||
        (user.role == UserRole.student && _isTeacherLogin)) {
      setState(() {
        _errorMessage = 'Please use the correct login type';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    // Navigate to the appropriate dashboard
    if (user.role == UserRole.teacher) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherDashboard(teacher: user),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDashboard(student: user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo/Title
                Icon(
                  Icons.school,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: kDefaultPadding),
                Text(
                  appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: kSmallPadding),
                Text(
                  _isTeacherLogin ? 'Teacher Login' : 'Student Login',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: kLargePadding),
                
                // Login Form
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCardBorderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kLargePadding),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                            ),
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                            ),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: kDefaultPadding),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: kLargePadding),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: kLargePadding),
                TextButton(
                  onPressed: _toggleLoginType,
                  child: Text(
                    _isTeacherLogin
                        ? 'Login as Student'
                        : 'Login as Teacher',
                  ),
                ),
                
                // Theme Toggle
                const SizedBox(height: kDefaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wb_sunny),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                    const Icon(Icons.nightlight_round),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

