import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 26),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 88),
              ),
              const SizedBox(height: 42),
              Text('Booking Confirmed!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),
              Text('Your table is reserved.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.muted,
                      )),
              const SizedBox(height: 42),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Text('Booking Reference',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          booking.reference,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          tooltip: 'Copy reference',
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: booking.reference));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Booking reference copied')),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'View My Bookings',
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HomeScreen(initialIndex: 1)),
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
