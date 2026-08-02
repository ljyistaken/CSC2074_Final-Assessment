import 'package:flutter/material.dart';

import '../app.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/restaurant_image.dart';
import 'booking_confirmed_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    final controller = BookingScope.of(context);
    final restaurant = controller.selectedRestaurant!;
    return AppScaffold(
      bottom: AppButton(
        label: submitting ? 'Confirming...' : 'Confirm Booking',
        onPressed: submitting
            ? null
            : () async {
                setState(() => submitting = true);
                final booking = await controller.confirmBooking();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingConfirmedScreen(booking: booking),
                  ),
                  (route) => route.isFirst,
                );
              },
      ),
      child: ListView(
        children: [
          Text('Booking Summary',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(restaurant.cuisineLabel),
                    ],
                  ),
                ),
                RestaurantImage(
                  imageKey: restaurant.imageKey,
                  imageData: restaurant.imageData,
                  width: 130,
                  height: 100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SummaryRow(label: 'Date', value: fullDate(controller.selectedDate)),
          _SummaryRow(label: 'Time', value: timeLabel(controller.selectedHour)),
          _SummaryRow(
              label: 'Party Size', value: partySizeLabel(controller.partySize)),
          _SummaryRow(label: 'Table Type', value: controller.tableType),
          _SummaryRow(
            label: 'Special Request',
            value: controller.specialRequest.isEmpty
                ? '—'
                : controller.specialRequest,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? AppColors.ink : AppColors.muted,
                fontWeight: FontWeight.w800,
                fontSize: strong ? 18 : 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: strong ? 20 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}