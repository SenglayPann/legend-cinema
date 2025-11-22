import 'package:flutter/material.dart';

class DateBar extends StatefulWidget {
  final bool isNowShowing;

  const DateBar({super.key, required this.isNowShowing});

  @override
  State<DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<DateBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isNowShowing) {
      final labels = ["Today", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

      return SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: labels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));

            return GestureDetector(
              onTap: () => setState(() => selectedIndex = index),
              child: _SelectablePill(
                width: 60,
                height: 80,
                isSelected: selectedIndex == index,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      index == 0 ? "Today" : labels[date.weekday],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      date.day.toString(),
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
      final months = ["October", "November", "December", "January"];

      return SizedBox(
        height: 35,
        child: ListView.separated(
          
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: months.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => setState(() => selectedIndex = index),
              child: _SelectablePill(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                isSelected: selectedIndex == index,
                child: Text(
                  months[index],
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
