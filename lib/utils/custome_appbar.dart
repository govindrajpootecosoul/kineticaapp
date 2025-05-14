import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String rangeLabel, DateTime? startDate, DateTime? endDate)? onRangeSelected;

  CustomAppBar({this.onRangeSelected});

  @override
  Size get preferredSize => const Size.fromHeight(100); // Adjust as needed

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final List<String> options = [
    'Today',
    'This Week',
    'Last 30 Days',
    'Last 6 Months',
    'Last 12 Months',
    'Custom Range',
  ];

  String selectedOption = 'Today';
  String displayText = '';
  DateTime? customStart;
  DateTime? customEnd;

  final formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _updateRange('Today');
  }

  void _updateRange(String option) async {
    final now = DateTime.now();

    switch (option) {
      case 'Today':
        displayText = formatter.format(now);
        widget.onRangeSelected?.call(option, now, now);
        break;

      case 'This Week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        displayText = '${formatter.format(start)} → ${formatter.format(now)}';
        widget.onRangeSelected?.call(option, start, now);
        break;

      case 'Last 30 Days':
        final start = now.subtract(const Duration(days: 30));
        displayText = '${formatter.format(start)} → ${formatter.format(now)}';
        widget.onRangeSelected?.call(option, start, now);
        break;

      case 'Last 6 Months':
        final start = DateTime(now.year, now.month - 6, now.day);
        displayText = '${formatter.format(start)} → ${formatter.format(now)}';
        widget.onRangeSelected?.call(option, start, now);
        break;

      case 'Last 12 Months':
        final start = DateTime(now.year - 1, now.month, now.day);
        displayText = '${formatter.format(start)} → ${formatter.format(now)}';
        widget.onRangeSelected?.call(option, start, now);
        break;

      case 'Custom Range':
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: now,
        );
        if (picked != null) {
          customStart = picked.start;
          customEnd = picked.end;
          displayText =
          '${formatter.format(customStart!)} → ${formatter.format(customEnd!)}';
          widget.onRangeSelected?.call(option, customStart, customEnd);
        }
        break;
    }

    setState(() {
      selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      AppBar(
      backgroundColor: Colors.blue,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 30),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: selectedOption,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.black),
            onChanged: (value) {
              if (value != null) _updateRange(value);
            },
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
          Text(
            displayText,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}

