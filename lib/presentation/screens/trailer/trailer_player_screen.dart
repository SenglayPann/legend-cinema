import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class TrailerPlayerScreen extends StatelessWidget {
  final String trailerUrl;

  const TrailerPlayerScreen({super.key, required this.trailerUrl});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Trailer",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Playing Trailer",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                trailerUrl,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            // TODO: Implement actual video player here using youtube_player_flutter or video_player
          ],
        ),
      ),
    );
  }
}
