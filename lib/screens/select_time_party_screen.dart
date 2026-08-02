import 'package:flutter/material.dart';

import '../app.dart';
import '../utils/date_formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/choice_chip_group.dart';
import 'booking_summary_screen.dart';

class SelectTimePartyScreen extends StatefulWidget {
  const SelectTimePartyScreen({super.key});

  @override
  State<SelectTimePartyScreen> createState() => _SelectTimePartyScreenState();
}

class _SelectTimePartyScreenState extends State<SelectTimePartyScreen> {
  late final TextEditingController requestController;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    requestController = TextEditingController(
      text: BookingScope.of(context).specialRequest,
    );
    initialized = true;
  }

  @override
  void dispose() {
    requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = BookingScope.of(context);
    const hours = [10, 11, 12, 13, 14, 15, 18, 19, 20];
    const tableTypes = [
      'Any available',
      'Window seat',
      'Indoor',
      'Outdoor',
    ];
    return AppScaffold(
      bottom: AppButton(
        label: 'Next',
        onPressed: () {
          controller.updateDraft(
            newSpecialRequest: requestController.text.trim(),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingSummaryScreen()),
          );
        },
      ),
      child: ListView(
        children: [
          Text('Selected Date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(fullDate(controller.selectedDate)),
          const SizedBox(height: 32),
          Text('Available Time Slots',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hours
                .map((hour) => AppChoiceChip(
                      label: timeLabel(hour),
                      value: hour,
                      selectedValue: controller.selectedHour,
                      onSelected: controller.selectHour,
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
                      selectedValue: controller.partySize,
                      onSelected: controller.selectPartySize,
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
                      selectedValue: controller.tableType,
                      onSelected: (value) =>
                          controller.updateDraft(newTableType: value),
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
}
