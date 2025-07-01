import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/admin_screen.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'قائمة Glowette',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text(
              'الرئيسية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text(
              'صفحة الأدمن',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();

              final session = Supabase.instance.client.auth.currentSession;
              if (session != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}