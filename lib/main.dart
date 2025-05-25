import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/utils/routes.dart';
import 'dart:async';
import 'package:flutter_application_3/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'your-supabase-url-here',
    anonKey: 'your-anon-key-here', 
  );

  runApp(const EcoCycleApp());
}

class EcoCycleApp extends StatelessWidget {
  const EcoCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoCycle',
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      initialRoute: '/', // Initial route set to '/' (SplashScreen)
      onGenerateRoute: AppRoutes.generateRoute, // Define route generator
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    _fadeController.forward();

    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(), // Changed LoginPage to LoginScreen
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(seconds: 2),
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(135, 42, 75, 44),
                    // ignore: deprecated_member_use
                    const Color.fromARGB(129, 40, 76, 50).withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Logo and Text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,  // Align content at the top
                children: [
                  const SizedBox(height: 200),  // Add spacing from the top
                  Image.asset(
                    'assets/eco.png',
                    color: Colors.white,
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "EcoCycle",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
}