import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateBar extends StatefulWidget {
  final bool isNowShowing;
  final Function(DateTime) onDateSelected;
  final Set<DateTime>? availableDates; // Dates that have showtimes
  final DateTime? initialSelectedDate; // Default selected date

  const DateBar({
    super.key,
    required this.isNowShowing,
    required this.onDateSelected,
    this.availableDates,
    this.initialSelectedDate,
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
    _setInitialSelectedIndex();
  }

  @override
  void didUpdateWidget(covariant DateBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isNowShowing != widget.isNowShowing) {
      _generateDates();
      _setInitialSelectedIndex();
      // Notify parent of the selected date when switching modes
      if (dates.isNotEmpty && selectedIndex < dates.length) {
        widget.onDateSelected(dates[selectedIndex]);
      }
    } else if (oldWidget.availableDates != widget.availableDates ||
        oldWidget.initialSelectedDate != widget.initialSelectedDate) {
      _setInitialSelectedIndex();
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

  void _setInitialSelectedIndex() {
    if (widget.initialSelectedDate != null && widget.isNowShowing) {
      // Find the index of the initial selected date
      for (int i = 0; i < dates.length; i++) {
        if (_isSameDay(dates[i], widget.initialSelectedDate!)) {
          selectedIndex = i;
          return;
        }
      }
    }

    // Default to first available date if availableDates is provided
    if (widget.availableDates != null &&
        widget.availableDates!.isNotEmpty &&
        widget.isNowShowing) {
      for (int i = 0; i < dates.length; i++) {
        if (_isDateAvailable(dates[i])) {
          selectedIndex = i;
          return;
        }
      }
    }

    selectedIndex = 0;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDateAvailable(DateTime date) {
    if (widget.availableDates == null) return true;
    return widget.availableDates!.any((d) => _isSameDay(d, date));
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
            final isAvailable = _isDateAvailable(date);

            return GestureDetector(
              onTap: isAvailable
                  ? () {
                      setState(() => selectedIndex = index);
                      widget.onDateSelected(date);
                    }
                  : null,
              child: _SelectablePill(
                width: 60,
                height: 80,
                isSelected: selectedIndex == index,
                isDisabled: !isAvailable,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: isAvailable ? Colors.white : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dayNumber,
                      style: TextStyle(
                        color: isAvailable ? Colors.white : Colors.white38,
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
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const _SelectablePill({
    required this.child,
    required this.isSelected,
    this.isDisabled = false,
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
        color: isDisabled ? Colors.grey.shade900 : Colors.black,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDisabled
              ? Colors.grey.shade800
              : (isSelected ? Colors.red : Colors.grey.shade700),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Center(child: child),
    );
  }
}
