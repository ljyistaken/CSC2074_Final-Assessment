import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: BorderRadius.circular(38),
                  ),
                  child: Center(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.dinner_dining_rounded,
                        color: Colors.white,
                        size: 92,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Delicious moments\nstart here',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 22),
              Text(
                'Book your favorite restaurants\nanytime, anywhere.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.muted,
                      height: 1.7,
                    ),
              ),
              const Spacer(),
              AppButton(
                label: 'Get Started',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
