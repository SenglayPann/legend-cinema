import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/showtime_model.dart';
import '../../screens/seat_layout/seat_layout_screen.dart';

class CinemaShowtimeListTile extends StatefulWidget {
  final String cinemaName;
  final List<ShowtimeModel> showtimes;

  const CinemaShowtimeListTile({
    super.key,
    required this.cinemaName,
    required this.showtimes,
  });

  @override
  State<CinemaShowtimeListTile> createState() => _CinemaShowtimeListTileState();
}

class _CinemaShowtimeListTileState extends State<CinemaShowtimeListTile> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent, // Body is transparent
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header (Title only background)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(
                  0.1,
                ), // Low black opacity for title
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.cinemaName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Body (Transparent)
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // Explicitly transparent
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(children: _buildCinemaShowtimes(widget.showtimes)),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCinemaShowtimes(List<ShowtimeModel> showtimes) {
    final subGroup = <String, List<ShowtimeModel>>{};
    for (var s in showtimes) {
      final key = "${s.screenType} - ${s.features.join(', ')}";
      if (!subGroup.containsKey(key)) {
        subGroup[key] = [];
      }
      subGroup[key]!.add(s);
    }

    return subGroup.entries.map((entry) {
      final label = entry.key;
      final times = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, // "2D - English"
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: times.map((t) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatLayoutScreen(showtime: t),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 8,
                          ),
                          child: Text(
                            t.showTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white10),
          ],
        ),
      );
    }).toList();
  }
}
