import 'package:flutter/material.dart';

class TabSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const TabSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 49, 49),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tab(context, "Now Showing", 0),
          _tab(context, "Coming Soon", 1),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String title, int index) {
    final bool isActive = index == selectedIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.white.withOpacity(0.3), // ripple color
          highlightColor: Colors.white.withOpacity(0.1), // pressed background tint
          onTap: () => onChanged(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.red : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
