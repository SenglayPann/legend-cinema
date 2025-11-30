import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class MovieDetailScreen extends StatelessWidget {
  final String movieId;
  final String cinemaName;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    required this.cinemaName,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Movie Details",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              "Movie ID: $movieId",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Selected Cinema: $cinemaName",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            // TODO: Fetch and display full movie details
          ],
        ),
      ),
    );
  }
}
