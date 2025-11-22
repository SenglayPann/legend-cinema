import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final Map<String, String> movie;
  final bool isComingSoon;

  const MovieCard({super.key, required this.movie, required this.isComingSoon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Movie poster
                Image.network(
                  movie["poster"]!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),

                // Advance Ticket label
                if (isComingSoon)
                  Positioned(
                    top: 30,
                    left: -40, // adjust to align with rotation
                    child: Transform.rotate(
                      angle: -0.785398, // -45° in radians
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 4,
                        ),
                        color: Colors.red,
                        child: const Text(
                          "Advance Ticket",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(movie["title"]!, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
