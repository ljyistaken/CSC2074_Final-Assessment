import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'change_password_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'my_bookings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFFFE3E1),
                    child: Text('AB',
                        style: TextStyle(
                            color: AppColors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                  SizedBox(height: 10),
                  Text('ABBY',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Abby@example.com',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 14, bottom: 4),
              child: Text('ACCOUNT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
            const _SettingsTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'View or edit your profile details',
            ),
            const _SettingsTile(
              icon: Icons.mail_outline,
              title: 'Email Address',
              subtitle: 'oscar.tan@example.com',
            ),
            _SettingsTile(
              icon: Icons.bookmark_outline,
              title: 'My Booking',
              subtitle: 'The Olive Kitchen 01:00PM Friday',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              ),
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              ),
              child: const Text('LOG OUT',
                  style: TextStyle(
                      color: AppColors.red, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.soft,
        child: Icon(icon, color: AppColors.red, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
