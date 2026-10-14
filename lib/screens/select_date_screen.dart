import 'package:flutter/material.dart';

import '../app.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import 'select_time_party_screen.dart';

class SelectDateScreen extends StatelessWidget {
  const SelectDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BookingScope.of(context);
    // Never hand the calendar a date before its firstDate -- it asserts.
    // Covers a stale selection (e.g. the app left open past midnight).
    final today = DateUtils.dateOnly(DateTime.now());
    final date = controller.selectedDate.isBefore(today)
        ? today
        : controller.selectedDate;
    return AppScaffold(
      bottom: AppButton(
        label: 'Next',
        onPressed: () {
          // Keep the controller in sync if the date was clamped above and
          // the user didn't tap a day themselves.
          if (controller.selectedDate.isBefore(today)) {
            controller.selectDate(today);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SelectTimePartyScreen()),
          );
        },
      ),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text('Select Date',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          CalendarDatePicker(
            initialDate: date,
            firstDate: today,
            lastDate: today.add(const Duration(days: 365)),
            onDateChanged: controller.selectDate,
          ),
          const SizedBox(height: 28),
          Text('Selected Date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(fullDate(date),
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}