import 'package:flutter/material.dart';

import '../app.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import 'booking_details_screen.dart';
import 'home_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({
    super.key,
    this.embedded = false,
    this.onBack,
  });

  final bool embedded;
  final VoidCallback? onBack;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  BookingStatus? selectedStatus = BookingStatus.confirmed;

  @override
  Widget build(BuildContext context) {
    final all = BookingScope.of(context).bookings;
    final bookings = switch (selectedStatus) {
      BookingStatus.cancelled =>
        all.where((item) => item.status == BookingStatus.cancelled).toList(),
      null => all
          .where((item) =>
              item.status != BookingStatus.cancelled &&
              item.dateTime.isBefore(DateTime.now()))
          .toList(),
      _ => all
          .where((item) =>
              item.status != BookingStatus.cancelled &&
              item.dateTime.isAfter(DateTime.now()))
          .toList(),
    };
    final body = SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.embedded) ...[
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back to Explore',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'My Bookings',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            SegmentedButton<BookingStatus?>(
              segments: const [
                ButtonSegment(
                    value: BookingStatus.confirmed, label: Text('Upcoming')),
                ButtonSegment(value: null, label: Text('Past')),
                ButtonSegment(
                    value: BookingStatus.cancelled, label: Text('Cancelled')),
              ],
              selected: {selectedStatus},
              showSelectedIcon: false,
              onSelectionChanged: (value) =>
                  setState(() => selectedStatus = value.first),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: bookings.isEmpty
                  ? const Center(child: Text('No bookings in this section.'))
                  : ListView.separated(
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, index) =>
                          _BookingCard(booking: bookings[index]),
                    ),
            ),
          ],
        ),
      ),
    );
    return widget.embedded
        ? body
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                tooltip: 'Back to Settings',
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
              title: const Text(
                'My Bookings',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            body: body,
          );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (booking.status) {
      BookingStatus.confirmed => AppColors.success,
      BookingStatus.pending => AppColors.warning,
      BookingStatus.cancelled => AppColors.muted,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(bookingId: booking.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthName(booking.dateTime.month)
                        .substring(0, 3)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.redDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('${booking.dateTime.day}',
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.restaurantName,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    '${timeLabel(booking.dateTime.hour)} · ${partySizeLabel(booking.partySize)}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    booking.status.name[0].toUpperCase() +
                        booking.status.name.substring(1),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}