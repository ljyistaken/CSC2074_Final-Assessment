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
    final date = controller.selectedDate;
    return AppScaffold(
      bottom: AppButton(
        label: 'Next',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectTimePartyScreen()),
        ),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text('Select Date',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          CalendarDatePicker(
            initialDate: date,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
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
