import 'package:flutter/material.dart';

class MovieInfoIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  const MovieInfoIcon({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.red, size: 18),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
