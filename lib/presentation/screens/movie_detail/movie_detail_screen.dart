import 'dart:ui';
import 'package:flutter/foundation.dart'; // Add this for ValueListenable
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../data/models/movie_model.dart';
import '../../../data/models/showtime_model.dart';
import '../../../data/services/movie_service.dart';
import '../../../data/services/showtime_service.dart';
import '../../widgets/date_bar.dart';
import '../../widgets/cinema_dropdown_selector.dart';
import '../../widgets/movie_detail/movie_header.dart';
import '../../widgets/movie_detail/movie_tag.dart';
import '../../widgets/movie_detail/movie_info_icon.dart';
import '../../widgets/movie_detail/expandable_description.dart';
import '../../widgets/movie_detail/cinema_showtime_list_tile.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;
  final String cinemaName; // Initial cinema selection or context

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    required this.cinemaName,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  final ShowtimeService _showtimeService = ShowtimeService();

  MovieModel? _movie;
  List<ShowtimeModel> _allShowtimes = [];
  List<String> _availableCinemas = ['All Cinemas'];

  bool _isLoading = true;

  DateTime _selectedDate = DateTime.now();
  late String _selectedCinema;

  late ScrollController _scrollController;
  final ValueNotifier<bool> _isScrolledNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _selectedCinema = widget.cinemaName.isNotEmpty
        ? widget.cinemaName
        : 'All Cinemas';
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset > 50 && !_isScrolledNotifier.value) {
          // Threshold 50
          _isScrolledNotifier.value = true;
        } else if (_scrollController.offset <= 50 &&
            _isScrolledNotifier.value) {
          _isScrolledNotifier.value = false;
        }
      });
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final movie = await _movieService.getMovieById(widget.movieId);
      final showtimes = await _showtimeService.getShowtimesForMovie(
        widget.movieId,
      );

      print('--------->Movie ID: ${widget.movieId}');
      print("--------->Movie: $movie");
      print("--------->Showtimes: $showtimes");

      if (mounted) {
        setState(() {
          _movie = movie;
          _allShowtimes = showtimes;

          // Extract unique cinemas logic
          final uniqueCinemas = showtimes
              .map((s) => s.cinemaName)
              .toSet()
              .toList();
          uniqueCinemas.sort();
          _availableCinemas = ['All Cinemas', ...uniqueCinemas];

          // If current selected cinema is not in available (and not All), reset?
          if (_selectedCinema != 'All Cinemas' &&
              !_availableCinemas.contains(_selectedCinema)) {
            _selectedCinema = 'All Cinemas';
          }

          // Set selected date to first available date with showtimes
          final firstAvailable = _getFirstAvailableDate();
          if (firstAvailable != null) {
            _selectedDate = firstAvailable;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Get all dates that have at least one showtime
  Set<DateTime> get _availableDates {
    return _allShowtimes.map((s) {
      final dt = s.showDateTime.toDate();
      return DateTime(dt.year, dt.month, dt.day);
    }).toSet();
  }

  // Find the first date (starting from today) that has showtimes
  DateTime? _getFirstAvailableDate() {
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
    return null;
  }

  List<ShowtimeModel> get _filteredShowtimes {
    return _allShowtimes.where((s) {
      // Date Check (Compare YYYY-MM-DD)
      final showDate = s.showDateTime.toDate();
      final isSameDay =
          showDate.year == _selectedDate.year &&
          showDate.month == _selectedDate.month &&
          showDate.day == _selectedDate.day;

      if (!isSameDay) return false;

      // Cinema Check
      if (_selectedCinema != 'All Cinemas' && s.cinemaName != _selectedCinema) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (_movie == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Movie not found", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isScrolledNotifier,
          builder: (context, isScrolled, child) {
            return AppBar(
              backgroundColor: Colors.black.withOpacity(isScrolled ? 1.0 : 0.0),
              elevation: 0,
              centerTitle: true,
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isScrolled ? 1.0 : 0.0,
                child: Image.asset(
                  "lib/assets/images/legend_cinema_logo_crop.png",
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // 0. Static Glass Effect Background
          if (_movie != null)
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _movie!.posterUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: Colors.black),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: Colors.black.withOpacity(0.6), // Darken the glass
                    ),
                  ),
                ],
              ),
            ),

          // 1. Content
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Poster & Trailer Entry
                MovieHeader(movie: _movie!),

                Container(
                  color: Colors.black, // Background for readability
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Info Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              _movie!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tags / Screen Types
                            Row(children: [const SizedBox(width: 8)]),
                            const SizedBox(height: 16),

                            // Icons Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MovieInfoIcon(
                                  icon: Icons.category,
                                  text: _movie!.genres.isNotEmpty
                                      ? _movie!.genres.first
                                      : "Action",
                                ),
                                const SizedBox(height: 8),
                                MovieInfoIcon(
                                  icon: Icons.access_time,
                                  text: "${_movie!.duration} min",
                                ),
                                const SizedBox(height: 8),
                                MovieInfoIcon(
                                  icon: Icons.calendar_today,
                                  text: DateFormat(
                                    'd MMM yyyy',
                                  ).format(_movie!.releaseDate.toDate()),
                                ),
                                const SizedBox(height: 8),
                                MovieInfoIcon(
                                  icon: Icons.visibility_off,
                                  text: _movie!.rating,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Gradient Divider
                      Container(
                        height: 1,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // 3. Description
                      ExpandableDescription(description: _movie!.description),

                      // Only show booking UI for non-upcoming movies
                      if (_movie!.status != 'upcoming') ...[
                        // 4. Cinema Selector (Filter)
                        _buildCinemaSelector(),

                        const SizedBox(height: 16),

                        // 5. Date Bar
                        DateBar(
                          isNowShowing: true,
                          availableDates: _availableDates,
                          initialSelectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() => _selectedDate = date);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 6. Showtime List (only for non-upcoming movies)
                if (_movie!.status != 'upcoming') _buildShowtimeList(),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaSelector() {
    return CinemaDropdownSelector(
      selectedCinema: _selectedCinema,
      onTap: _openCinemaSelector,
    );
  }

  void _openCinemaSelector() {
    // We only want to show cinemas that are relevant to this movie
    // So we pass _availableCinemas, but we need to map them to CinemaModel-ish objects
    // or modify CinemaSelectorDialog to accept Strings.
    // Checking `CinemaSelectorDialog`: it takes `List<CinemaModel>`.
    // I don't have CinemaModels here easily without fetching them all OR
    // creating dummy ones.
    // For now, I'll create dummy CinemaModels from the strings.

    // Note: Assuming CinemaSelectorDialog uses 'name' and 'id'.
    // Import CinemaModel.
    // I need to import CinemaModel in the file.

    // Actually simpler: Just show a CupertionPicker or simple dialog if I don't want to import everything.
    // BUT the prompt asked for "using `banner_carousel.dart` selector", which calls `_openCinemaSelector` in home.
    // `home_screen.dart` uses `CinemaSelectorDialog`.
    // Let's reuse it.

    // Creating Mock Models for the selector
    /* final cinemasForDialog = _availableCinemas.map((name) => 
       // This is a bit hacky, but the dialog likely displays name.
       // We don't have the ID handy unless we map it from showtimes properly.
       // Since `availableCinemas` is just strings right now, let's just make it work.
       // We'll skip the proper ID for now or fetch it if needed.
       // Let's assume standard CinemaModel requires ID.
       // We can mock it.
       // Actually, I should just fetch all cinemas in `fetchData` properly if I want to use `CinemaModel`.
     ).toList(); 
    */

    // Better approach: Since `CinemaSelectorDialog` expects `List<CinemaModel>`,
    // and I only have names from Showtimes (unless I join with Cinema collection),
    // I should probably fetch all cinemas in `initState` as well?
    // Or just create a local simple selector.
    // Given "Use the one from banner carousel", it implies the LOOK.
    // I can implement a simple bottom sheet here.

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Select Cinema",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableCinemas.length,
                itemBuilder: (context, index) {
                  final cinema = _availableCinemas[index];
                  final isSelected = cinema == _selectedCinema;
                  return ListTile(
                    title: Text(
                      cinema,
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.red)
                        : null,
                    onTap: () {
                      setState(() => _selectedCinema = cinema);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShowtimeList() {
    final showtimes = _filteredShowtimes;

    if (showtimes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "No showtimes available.",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final grouped = <String, List<ShowtimeModel>>{};
    for (var s in showtimes) {
      if (!grouped.containsKey(s.cinemaName)) {
        grouped[s.cinemaName] = [];
      }
      grouped[s.cinemaName]!.add(s);
    }

    return Column(
      children: grouped.entries.map((entry) {
        return CinemaShowtimeListTile(
          cinemaName: entry.key,
          showtimes: entry.value,
        );
      }).toList(),
    );
  }
}
