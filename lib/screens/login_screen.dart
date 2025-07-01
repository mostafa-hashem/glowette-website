import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_screen.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        CustomToast.showSuccess(
          context,
          "مرحباً بعودتك! تم تسجيل الدخول بنجاح إلى لوحة الإدارة.",
        );
        
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AdminScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        CustomToast.showError(
          context,
          e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(
          context,
          'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDF8F5),
              Color(0xFFF8E8E9),
              Color(0xFFF4D3D5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 20,
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE57F84).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  size: 60,
                                  color: Color(0xFFE57F84),
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              const Text(
                                'مدير تطبيق Glowette',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4E4A47),
                                  letterSpacing: 1,
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                              
                              const Text(
                                'أهلاً بعودتك! يرجى تسجيل الدخول للمتابعة',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8B7D7D),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 40),
                              
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'عنوان البريد الإلكتروني',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F8F8),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال البريد الإلكتروني';
                                  }
                                  if (!value.contains('@')) {
                                    return 'يرجى إدخال بريد إلكتروني صحيح';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword 
                                          ? Icons.visibility_off 
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F8F8),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال كلمة المرور';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 40),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: _isLoading
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: const Color(0xFFE57F84).withValues(alpha: 0.1),
                                        ),
                                        child: const Center(
                                          child: LoadingIndicator(size: 30),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _signIn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE57F84),
                                          foregroundColor: Colors.white,
                                          elevation: 8,
                                          shadowColor: const Color(0xFFE57F84).withValues(alpha: 0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: const Text(
                                          'تسجيل الدخول',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
