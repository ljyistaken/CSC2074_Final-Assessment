import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

class BookingUpdatedScreen extends StatelessWidget {
  const BookingUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Change',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 126,
                height: 126,
                decoration: const BoxDecoration(
                    color: AppColors.red, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 68),
              ),
              const SizedBox(height: 40),
              Text('Booking Updated',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              const Text('Your booking has been updated\nsuccessfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted)),
              const Spacer(),
              AppButton(
                label: 'Back to My Booking',
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(initialIndex: 1),
                  ),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
