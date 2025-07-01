import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _startAnimations();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF8F5),
              Color(0xFFF8E8E9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE57F84).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.25,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_mall,
                                size: screenWidth * 0.25,
                                color: const Color(0xFFE57F84),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Glowette ✨',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4E4A47),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'رحلة جمالك تبدأ من هنا',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B7D7D),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const LoadingIndicator(size: 50),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'جاري تحضير إشراقتك...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB8A5A5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
