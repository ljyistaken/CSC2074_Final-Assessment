import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'admin_restaurants_screen.dart';
import 'change_password_screen.dart';
import 'my_bookings_screen.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final authService = AuthService();
  bool isAdmin = false;
  bool loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final admin = await authService.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() {
      isAdmin = admin;
      loadingRole = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Guest');
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
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
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFFFE3E1),
                    child: Text(initials.isEmpty ? '?' : initials,
                        style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 10),
                  Text(displayName.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(user?.email ?? '',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13)),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('ADMIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
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
            _SettingsTile(
              icon: Icons.mail_outline,
              title: 'Email Address',
              subtitle: user?.email ?? 'Not signed in',
            ),
            _SettingsTile(
              icon: Icons.bookmark_outline,
              title: 'My Booking',
              subtitle: 'View your upcoming reservations',
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
            if (isAdmin) ...[
              const Padding(
                padding: EdgeInsets.only(top: 14, bottom: 4),
                child: Text('ADMIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
              _SettingsTile(
                icon: Icons.restaurant_menu_outlined,
                title: 'Manage Restaurants',
                subtitle: 'Add, edit, or remove restaurants',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminRestaurantsScreen()),
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                await authService.signOut();
                if (!context.mounted) return;
                // Explicit reset + navigation rather than waiting on
                // Firebase's authStateChanges() stream, which was found
                // to be unreliable in Flutter Web dev sessions (see
                // app.dart for details).
                BookingScope.of(context).reset();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              },
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
    // Tiles with no onTap (Personal Information, Email Address) are
    // informational only — no edit screen exists for them yet. Dimmed and
    // without an arrow/ripple so that reads as intentional, not broken.
    final interactive = onTap != null;
    return Opacity(
      opacity: interactive ? 1 : 0.55,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.soft,
          child: Icon(icon, color: AppColors.red, size: 20),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        trailing: interactive
            ? const Icon(Icons.chevron_right, size: 20)
            : null,
      ),
    );
  }
}