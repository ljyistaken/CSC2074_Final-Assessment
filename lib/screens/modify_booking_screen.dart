import 'package:flutter/material.dart';

import '../app.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import 'booking_updated_screen.dart';

class ModifyBookingScreen extends StatefulWidget {
  const ModifyBookingScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  State<ModifyBookingScreen> createState() => _ModifyBookingScreenState();
}

class _ModifyBookingScreenState extends State<ModifyBookingScreen> {
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
    date = original.dateTime;
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
          const SizedBox(height: 28),
          _EditTile(
            label: 'Change Date',
            value: fullDate(date),
            onTap: pickDate,
          ),
          _EditTile(
            label: 'Change Time',
            value: timeLabel(hour),
            onTap: pickTime,
          ),
          _EditTile(
            label: 'Change Party Size',
            value: '$partySize People',
            onTap: pickPartySize,
          ),
          _EditTile(
            label: 'Change Table Type',
            value: tableType,
            onTap: pickTableType,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: requestController,
            decoration: const InputDecoration(labelText: 'Special Request'),
          ),
        ],
      ),
    );
  }

  Future<void> pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (value != null) setState(() => date = value);
  }

  Future<void> pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: 0),
    );
    if (value != null) setState(() => hour = value.hour);
  }

  Future<void> pickPartySize() async {
    final value = await _select<int>(
        'Party Size', [1, 2, 3, 4, 5, 6], (value) => '$value People');
    if (value != null) setState(() => partySize = value);
  }

  Future<void> pickTableType() async {
    final value = await _select<String>(
      'Table Type',
      ['Any available', 'Window seat', 'Indoor', 'Outdoor'],
      (value) => value,
    );
    if (value != null) setState(() => tableType = value);
  }

  Future<T?> _select<T>(
      String title, List<T> values, String Function(T) label) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final value in values)
                ListTile(
                  title: Text(label(value)),
                  onTap: () => Navigator.pop(context, value),
                ),
            ],
          ),
        ),
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

class _EditTile extends StatelessWidget {
  const _EditTile({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        title: Text(label,
            style: const TextStyle(
                color: AppColors.muted, fontWeight: FontWeight.w800)),
        trailing: SizedBox(
          width: 150,
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
