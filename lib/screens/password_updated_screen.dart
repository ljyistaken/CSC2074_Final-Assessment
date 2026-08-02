import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 128,
                height: 128,
                decoration: const BoxDecoration(
                    color: AppColors.red, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 70),
              ),
              const SizedBox(height: 42),
              Text('Password Changed',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              const Text('Your password has been updated\nsuccessfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted)),
              const Spacer(),
              AppButton(
                label: 'Back to Settings',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
