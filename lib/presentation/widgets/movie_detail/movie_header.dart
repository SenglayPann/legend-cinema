import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../screens/trailer/trailer_player_screen.dart';
import '../../../data/models/movie_model.dart';

class MovieHeader extends StatelessWidget {
  final MovieModel movie;

  const MovieHeader({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 2:1 Ratio
        AspectRatio(
          aspectRatio: 2 / 1,
          child: CachedNetworkImage(
            imageUrl: movie.posterUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
          ),
        ),
        // Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black, // Stronger at bottom
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        // Play Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TrailerPlayerScreen(trailerUrl: movie.trailerUrl),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
