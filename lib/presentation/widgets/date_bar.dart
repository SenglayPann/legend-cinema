import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class DateBar extends StatefulWidget {
  final bool isNowShowing;
  final Function(DateTime) onDateSelected;

  const DateBar({
    super.key,
    required this.isNowShowing,
    required this.onDateSelected,
  });

  @override
  State<DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<DateBar> {
  int selectedIndex = 0;
  late List<DateTime> dates;

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  @override
  void didUpdateWidget(covariant DateBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isNowShowing != widget.isNowShowing) {
      _generateDates();
      selectedIndex = 0;
      // Notify parent of the first date/month when switching modes
      if (dates.isNotEmpty) {
        widget.onDateSelected(dates[0]);
      }
    }
  }

  void _generateDates() {
    final now = DateTime.now();
    if (widget.isNowShowing) {
      // Generate next 7 days
      dates = List.generate(7, (index) => now.add(Duration(days: index)));
    } else {
      // Generate next 6 months
      dates = List.generate(6, (index) {
        return DateTime(now.year, now.month + index, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNowShowing) {
      return SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final date = dates[index];
            final isToday = index == 0;
            final dayName = isToday ? "Today" : DateFormat('E').format(date);
            final dayNumber = date.day.toString();

            return GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
                widget.onDateSelected(date);
              },
              child: _SelectablePill(
                width: 60,
                height: 80,
                isSelected: selectedIndex == index,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      dayNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        height: 35,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final date = dates[index];
            final monthName = DateFormat('MMMM').format(date);

            return GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
                widget.onDateSelected(date);
              },
              child: _SelectablePill(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                isSelected: selectedIndex == index,
                child: Text(
                  monthName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}

/// ---------------------------------------------------------
/// Reusable Pill Widget
/// ---------------------------------------------------------
class _SelectablePill extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const _SelectablePill({
    required this.child,
    required this.isSelected,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isSelected ? Colors.red : Colors.grey.shade700,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Center(child: child),
    );
  }
}
