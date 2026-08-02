import 'package:flutter/material.dart';

import '../app.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/choice_chip_group.dart';
import 'booking_updated_screen.dart';

/// Deliberately mirrors select_date_screen.dart + select_time_party_screen.dart
/// (same inline CalendarDatePicker, same hour/party-size/table-type chips,
/// same special request field) instead of using system date/time pickers.
/// The system `showTimePicker` dial doesn't fit well inside this app's
/// fixed-width layout frame and implies minute-level precision the app
/// doesn't actually support (bookings are hour slots only) -- reusing the
/// exact controls from the booking flow keeps editing consistent with
/// creating a booking and avoids both problems.
class ModifyBookingScreen extends StatefulWidget {
  const ModifyBookingScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  State<ModifyBookingScreen> createState() => _ModifyBookingScreenState();
}

class _ModifyBookingScreenState extends State<ModifyBookingScreen> {
  static const hours = [10, 11, 12, 13, 14, 15, 18, 19, 20];
  static const tableTypes = [
    'Any available',
    'Window seat',
    'Indoor',
    'Outdoor',
  ];

  late Booking original;
  late DateTime date;
  late int hour;
  late int partySize;
  late String tableType;
  late TextEditingController requestController;
  bool initialized = false;
  bool saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    original = BookingScope.of(context)
        .bookings
        .firstWhere((item) => item.id == widget.bookingId);
    date = DateTime(
      original.dateTime.year,
      original.dateTime.month,
      original.dateTime.day,
    );
    hour = original.dateTime.hour;
    partySize = original.partySize;
    tableType = original.tableType;
    requestController = TextEditingController(text: original.specialRequest);
    initialized = true;
  }

  @override
  void dispose() {
    if (initialized) requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottom: AppButton(
        label: saving ? 'Saving...' : 'Save Changes',
        onPressed: saving ? null : save,
      ),
      child: ListView(
        children: [
          Text('Modify Booking',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text('Date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          CalendarDatePicker(
            initialDate: date,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (value) => setState(
              () => date = DateTime(value.year, value.month, value.day),
            ),
          ),
          const SizedBox(height: 24),
          Text('Time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hours
                .map((value) => AppChoiceChip(
                      label: timeLabel(value),
                      value: value,
                      selectedValue: hour,
                      onSelected: (value) => setState(() => hour = value),
                    ))
                .toList(),
          ),
          const SizedBox(height: 30),
          Text('Party Size', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [1, 2, 3, 4, 5]
                .map((size) => AppChoiceChip(
                      label: size == 5 ? '5+' : '$size',
                      value: size,
                      selectedValue: partySize,
                      onSelected: (value) => setState(() => partySize = value),
                    ))
                .toList(),
          ),
          const SizedBox(height: 30),
          Text('Table Preference',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 8,
            children: tableTypes
                .map((type) => AppChoiceChip(
                      label: type,
                      value: type,
                      selectedValue: tableType,
                      onSelected: (value) => setState(() => tableType = value),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: requestController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Special Request (optional)',
              hintText: 'E.g. birthday setup or allergy note',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> save() async {
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
        title: const Text('Confirm Changes'),
        content: const Text(
          'Are you sure you want to modify your booking?',
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
    if (accepted != true || !mounted) return;
    setState(() => saving = true);
    await BookingScope.of(context).updateBooking(
      original.copyWith(
        dateTime: DateTime(date.year, date.month, date.day, hour),
        partySize: partySize,
        tableType: tableType,
        specialRequest: requestController.text.trim(),
      ),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BookingUpdatedScreen()),
    );
  }
}