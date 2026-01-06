import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/showtime_model.dart';
import './movie_grid.dart';
import '../widgets/tab_selector.dart';

class MovieTabs extends StatelessWidget {
  final List<MovieModel> nowShowing;
  final Map<String, List<ShowtimeModel>> movieShowtimes;
  final List<MovieModel> comingSoon;
  final List<OfferModel> offers;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final String selectedCinema;

  const MovieTabs({
    super.key,
    required this.nowShowing,
    this.movieShowtimes = const {},
    required this.comingSoon,
    required this.offers,
    required this.selectedTabIndex,
    required this.onTabChanged,
    this.selectedCinema = 'All Cinemas',
  });

  @override
  Widget build(BuildContext context) {
    final isComingSoon = selectedTabIndex == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// -------------------------------
        /// CUSTOM TAB SELECTOR
        /// -------------------------------
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabSelector(
              selectedIndex: selectedTabIndex,
              onChanged: onTabChanged,
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// -------------------------------
        /// STACK WITH FADE TRANSITION
        /// -------------------------------
        AnimatedCrossFade(
          firstChild: MovieGrid(
            movies: nowShowing,
            movieShowtimes: movieShowtimes,
            selectedCinema: selectedCinema,
            isComingSoon: false,
            offers: offers,
          ),
          secondChild: MovieGrid(
            movies: comingSoon,
            selectedCinema: selectedCinema,
            isComingSoon: true,
          ),
          crossFadeState: isComingSoon
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
        ),
      ],
    );
  }
}
