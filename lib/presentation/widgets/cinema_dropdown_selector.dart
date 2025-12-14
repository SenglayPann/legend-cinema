import 'package:flutter/material.dart';

class CinemaDropdownSelector extends StatelessWidget {
  final String selectedCinema;
  final VoidCallback onTap;

  const CinemaDropdownSelector({
    super.key,
    required this.selectedCinema,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 45,
        decoration: BoxDecoration(
          color: const Color.fromARGB(80, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCinema,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
