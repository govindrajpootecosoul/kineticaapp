import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateDropdown extends StatefulWidget {
  final Function(DateTime? start, DateTime? end, String displayedText, String selectedOption) onDateRangeSelected;

  const DateDropdown({super.key, required this.onDateRangeSelected});

  @override
  State<DateDropdown> createState() => _DateDropdownState();
}

class _DateDropdownState extends State<DateDropdown> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String selectedOption = 'This Week';
  String displayedText = '';
  DateTime? customStartDate;
  DateTime? customEndDate;

  @override
  void initState() {
    super.initState();
    _handleSelection(selectedOption);
  }

  void _handleSelection(String selection) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (selection) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        displayedText = 'Today: ${formatter.format(now)}';
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = now.add(const Duration(days: 1));
        displayedText = 'This Week: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Last 30 Days':
        start = now.subtract(const Duration(days: 30));
        end = now.add(const Duration(days: 1));
        displayedText = 'Last 30 Days: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Last 6 Months':
        start = DateTime(now.year, now.month - 6, now.day);
        end = now.add(const Duration(days: 1));
        displayedText = 'Last 6 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Last 12 Months':
        start = DateTime(now.year - 1, now.month, now.day);
        end = now.add(const Duration(days: 1));
        displayedText = 'Last 12 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Custom Range':
        if (customStartDate != null && customEndDate != null) {
          start = customStartDate;
          end = customEndDate!.add(const Duration(days: 1));
          displayedText = 'Custom: ${formatter.format(customStartDate!)} -- ${formatter.format(customEndDate!)}';
        } else {
          displayedText = 'Please select a custom range.';
        }
        break;
    }

    setState(() {
      selectedOption = selection;
    });

    widget.onDateRangeSelected(start, end, displayedText, selectedOption);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        customStartDate = picked.start;
        customEndDate = picked.end;
      });
      _handleSelection('Custom Range');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<String>(
          value: selectedOption,
          items: [
            'Today',
            'This Week',
            'Last 30 Days',
            'Last 6 Months',
            'Last 12 Months',
            'Custom Range'
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              if (newValue == 'Custom Range') {
                _selectDateRange(context);
              } else {
                _handleSelection(newValue);
              }
            }
          },
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
