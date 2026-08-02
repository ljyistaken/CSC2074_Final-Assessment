import 'package:flutter/material.dart';

import '../app.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import 'modify_booking_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final controller = BookingScope.of(context);
    final booking =
        controller.bookings.firstWhere((item) => item.id == bookingId);
    return AppScaffold(
      bottom: booking.status == BookingStatus.cancelled
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: 'Modify Booking',
                  outlined: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ModifyBookingScreen(bookingId: booking.id),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Cancel Booking',
                  onPressed: () => _confirmCancel(context, booking),
                ),
              ],
            ),
      child: ListView(
        children: [
          Text(booking.restaurantName,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            '${timeLabel(booking.dateTime.hour)} · ${booking.partySize} People',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          Chip(
            label: Text(booking.status.name.toUpperCase()),
            side: const BorderSide(color: AppColors.border),
          ),
          const SizedBox(height: 22),
          _DetailRow(label: 'Date', value: fullDate(booking.dateTime)),
          _DetailRow(label: 'Time', value: timeLabel(booking.dateTime.hour)),
          _DetailRow(label: 'Party Size', value: '${booking.partySize} People'),
          _DetailRow(label: 'Table Type', value: booking.tableType),
          _DetailRow(
            label: 'Special Request',
            value:
                booking.specialRequest.isEmpty ? '—' : booking.specialRequest,
          ),
          _DetailRow(label: 'Reference', value: booking.reference),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, Booking booking) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('This booking will move to the Cancelled section.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Booking')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return;
    await BookingScope.of(context).cancelBooking(booking);
    if (context.mounted) Navigator.pop(context);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.muted, fontWeight: FontWeight.w800))),
          const SizedBox(width: 14),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
