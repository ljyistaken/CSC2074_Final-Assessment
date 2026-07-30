import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'password_updated_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final confirmOldPassword = TextEditingController();
  final newPassword = TextEditingController();

  @override
  void dispose() {
    oldPassword.dispose();
    confirmOldPassword.dispose();
    newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            children: [
              Text('Change Password',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Enter your password details below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 40),
              _field('Old Password', oldPassword),
              _field('Confirm Old Password', confirmOldPassword,
                  validator: (value) => value == oldPassword.text
                      ? null
                      : 'Old passwords do not match'),
              _field('New Password', newPassword,
                  validator: (value) => (value?.length ?? 0) >= 6
                      ? null
                      : 'Use at least 6 characters'),
              const SizedBox(height: 16),
              AppButton(
                label: 'Continue',
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  _confirm(context);
                },
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.muted))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Enter $label'.toLowerCase()),
            validator: validator ??
                (value) =>
                    (value?.isNotEmpty ?? false) ? null : 'Required field',
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const CircleAvatar(
          radius: 32,
          backgroundColor: Color(0xFFFFE3E1),
          child: Text('?',
              style: TextStyle(
                  color: AppColors.red,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ),
        title: const Text('Confirm Password Change'),
        content: const Text(
          'Are you sure you want to change your account password?',
          textAlign: TextAlign.center,
        ),
        actions: [
          OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (accepted == true && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PasswordUpdatedScreen()),
      );
    }
  }
}
