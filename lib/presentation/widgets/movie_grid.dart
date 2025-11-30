import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/offer_model.dart';
import 'shared/movie_card.dart';
import 'shared/promotion_card.dart';
import 'date_bar.dart';
import '../screens/offer/offer_detail_screen.dart';
import '../screens/movie_detail/movie_detail_screen.dart';

class MovieGrid extends StatefulWidget {
  final List<MovieModel> movies;
  final String selectedCinema;
  final bool isComingSoon;
  final List<OfferModel> offers;

  const MovieGrid({
    super.key,
    required this.movies,
    this.selectedCinema = 'All Cinemas',
    this.isComingSoon = false,
    this.offers = const [],
  });

  @override
  State<MovieGrid> createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid> {
  DateTime _selectedDate = DateTime.now();

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  List<MovieModel> _getFilteredMovies() {
    if (!widget.isComingSoon) {
      // For "Now Showing", we assume movies are available daily as we lack showtime data.
      // So we return all movies regardless of the selected day.
      return widget.movies;
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
