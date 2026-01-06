import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/showtime_model.dart';
import 'shared/movie_card.dart';
import 'shared/promotion_card.dart';
import 'date_bar.dart';
import '../screens/offer/offer_detail_screen.dart';
import '../screens/movie_detail/movie_detail_screen.dart';

class MovieGrid extends StatefulWidget {
  final List<MovieModel> movies;
  final Map<String, List<ShowtimeModel>> movieShowtimes;
  final String selectedCinema;
  final bool isComingSoon;
  final List<OfferModel> offers;

  const MovieGrid({
    super.key,
    required this.movies,
    this.movieShowtimes = const {},
    this.selectedCinema = 'All Cinemas',
    this.isComingSoon = false,
    this.offers = const [],
  });

  @override
  State<MovieGrid> createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _getFirstAvailableDate() ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant MovieGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected date when movieShowtimes changes
    if (oldWidget.movieShowtimes != widget.movieShowtimes) {
      final firstAvailable = _getFirstAvailableDate();
      if (firstAvailable != null) {
        setState(() => _selectedDate = firstAvailable);
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // Get all dates that have at least one showtime
  Set<DateTime> get _availableDates {
    final Set<DateTime> dates = {};
    for (var showtimes in widget.movieShowtimes.values) {
      for (var showtime in showtimes) {
        final dt = showtime.showDateTime.toDate();
        dates.add(DateTime(dt.year, dt.month, dt.day));
      }
    }
    return dates;
  }

  // Find the first date (starting from today) that has showtimes
  DateTime? _getFirstAvailableDate() {
    if (!widget.isComingSoon) {
      final now = DateTime.now();
      final dates = List.generate(
        7,
        (i) => DateTime(now.year, now.month, now.day).add(Duration(days: i)),
      );

      for (var date in dates) {
        if (_availableDates.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        )) {
          return date;
        }
      }
    }
    return null;
  }

  List<MovieModel> _getFilteredMovies() {
    if (!widget.isComingSoon) {
      // For "Now Showing", filter by movies that have showtimes on the selected date
      return widget.movies.where((movie) {
        final showtimes = widget.movieShowtimes[movie.id] ?? [];
        return showtimes.any((showtime) {
          final showDate = showtime.showDateTime.toDate();
          return showDate.year == _selectedDate.year &&
              showDate.month == _selectedDate.month &&
              showDate.day == _selectedDate.day;
        });
      }).toList();
    } else {
      // For "Coming Soon", filter by month and year.
      return widget.movies.where((movie) {
        final releaseDate = movie.releaseDate.toDate();
        return releaseDate.year == _selectedDate.year &&
            releaseDate.month == _selectedDate.month;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _getFilteredMovies();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateBar(
          isNowShowing: !widget.isComingSoon,
          availableDates: widget.isComingSoon ? null : _availableDates,
          initialSelectedDate: widget.isComingSoon ? null : _selectedDate,
          onDateSelected: _onDateSelected,
        ),
        const SizedBox(height: 16),
        if (filteredMovies.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No movies available",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Adjusted for better card proportions
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) {
              final movie = filteredMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(
                        movieId: movie.id,
                        cinemaName: widget.selectedCinema,
                      ),
                    ),
                  );
                },
                child: MovieCard(
                  movie: movie,
                  isComingSoon: widget.isComingSoon,
                ),
              );
            },
          ),

        // Promotion Section (Only for Now Showing)
        if (!widget.isComingSoon && widget.offers.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Promotion",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.offers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final offer = widget.offers[index];

                      return SizedBox(
                        width: 280,
                        child: PromotionCard(
                          imageUrl: offer.imageUrl,
                          description: offer.description,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OfferDetailScreen(offer: offer),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
