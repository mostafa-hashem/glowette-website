import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:glowette/screens/splash_screen.dart';
import 'package:glowette/supabase_credentials.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const GlowetteApp());
}

class GlowetteApp extends StatelessWidget {
  const GlowetteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider()..initialize(),
      child: MaterialApp(
        title: 'Glowette',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'EG'),
        ],
        locale: const Locale('ar', 'EG'),
        theme: ThemeData(
          fontFamily: 'Almarai',
          scaffoldBackgroundColor: const Color(0xFFFDF8F5),
          primaryColor: const Color(0xFFE57F84),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE57F84),
            primary: const Color(0xFFE57F84),
            secondary: const Color(0xFFD4AF37),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF4E4A47)),
            titleTextStyle: TextStyle(
              fontFamily: 'Almarai',
              color: Color(0xFF4E4A47),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge:
                TextStyle(color: Color(0xFF4E4A47), fontWeight: FontWeight.bold),
            bodyMedium:
                TextStyle(color: Color(0xFF4E4A47), fontSize: 16, height: 1.7),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
