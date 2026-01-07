import 'package:flutter/material.dart';
import 'package:legend_cinema/data/models/cinema_model.dart';
import 'package:legend_cinema/data/models/movie_model.dart';
import 'package:legend_cinema/data/models/showtime_model.dart';
import 'package:legend_cinema/data/services/movie_service.dart';
import 'package:legend_cinema/presentation/widgets/app_scaffold.dart';
import 'package:legend_cinema/presentation/widgets/movie_grid.dart';
import 'package:legend_cinema/presentation/widgets/glass_container.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CinemaDetailScreen extends StatefulWidget {
  final CinemaModel cinema;

  const CinemaDetailScreen({super.key, required this.cinema});

  @override
  State<CinemaDetailScreen> createState() => _CinemaDetailScreenState();
}

class _CinemaDetailScreenState extends State<CinemaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MovieService _movieService = MovieService();

  List<MovieModel> _nowShowingMovies = [];
  Map<String, List<ShowtimeModel>> _movieShowtimes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final nowShowing = await _movieService.getNowShowingMovies();
      // We also need showtimes to filter by date/cinema in MovieGrid
      // MovieGrid takes all showtimes and filters them if selectedCinema is passed
      // But getNowShowingMovies returns movies, we need their showtimes too.
      // In HomeScreen, fetchNowShowing loads movies. MovieGrid takes movieShowtimes map.
      // Helper in HomeScreen: _fetchData fetches movies and for each movie fetches showtimes.

      // Let's optimize: We only care about showtimes for THIS cinema.
      // But MovieService doesn't have getShowtimesForCinema(cinemaId).
      // We can fetch all check logic in MovieGrid.
      // Actually, let's just re-use the logic from HomeScreen but filtered.

      Map<String, List<ShowtimeModel>> showtimesMap = {};

      // Optimization: For this screen we might want to fetch showtimes for all now showing movies
      // to populate the DateBar and Grid.
      // However, fetching showtimes for ALL movies just to filter for one cinema is inefficient if many movies.
      // But given current service structure:

      for (var movie in nowShowing) {
        final showtimes = await _movieService.getShowtimes(movie.id);
        // Filter showtimes for this cinema here if we want to save memory,
        // OR pass all to MovieGrid and let it filter.
        // MovieGrid logic:
        /* 
           final showtimes = widget.movieShowtimes[movie.id] ?? [];
           // then filter by cinema? No, MovieGrid filters by selectedCinema in _getFilteredMovies?
           // No, MovieGrid _getFilteredMovies uses _selectedDate filtering.
           // It relies on passing "selectedCinema" to the MovieDetailScreen navigation, 
           // BUT it DOES NOT filter the grid by cinema itself?
           // Wait, let me check MovieGrid again.
           
           In MovieGrid:
           // It does NOT seem to filter movies by cinema in _getFilteredMovies?
           // Wait, I see lines 94-95 in MovieGrid.dart
           /*
           return widget.movies.where((movie) {
             final showtimes = widget.movieShowtimes[movie.id] ?? [];
             return showtimes.any((showtime) { ... check date ... });
           }).toList();
           */ 
           It checks date. It doesn't seem to check cinema ID in that `any` clause?
           
           Ah, `widget.selectedCinema` is passed to `MovieDetailScreen`.
           But does the grid show movies that are NOT playing at this cinema?
           If I pass "selectedCinema" to MovieGrid, it doesn't seem to use it for filtering the list.
           
           So I MUST filter the movies/showtimes BEFORE passing to MovieGrid, 
           OR I need to update MovieGrid to filter by cinema.
           
           Given the user requirement "now showing movies in the cinema", 
           I should ensure `_nowShowingMovies` ONLY contains movies playing at this cinema.
        */

        final cinemaShowtimes = showtimes
            .where((s) => s.cinemaName == widget.cinema.name)
            .toList();
        if (cinemaShowtimes.isNotEmpty) {
          showtimesMap[movie.id] = cinemaShowtimes;
        }
      }

      final moviesAtCinema = nowShowing
          .where((m) => showtimesMap.containsKey(m.id))
          .toList();

      if (mounted) {
        setState(() {
          _nowShowingMovies = moviesAtCinema;
          _movieShowtimes = showtimesMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching cinema details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF090909),
              leading: IconButton(
                icon: const ContainerWithBackground(
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.cinema.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.cinema.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[900]),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.red,
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: "Now Showing"),
                    Tab(text: "Info"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: AnimatedCrossFade(
          firstChild: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: MovieGrid(
                      movies: _nowShowingMovies,
                      movieShowtimes: _movieShowtimes,
                      selectedCinema: widget.cinema.name,
                      isComingSoon: false,
                    ),
                  ),
                ),
          secondChild: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  title: "Address",
                  content: widget.cinema.address,
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        title: "Open Hour",
                        content: widget.cinema.openHour,
                        icon: Icons.access_time,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        title: "Close Hour",
                        content: widget.cinema.closeHour,
                        icon: Icons.access_time_filled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: "Halls",
                  content: "${widget.cinema.hallCount} Halls",
                  icon: Icons.chair,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: "Facilities",
                  content: widget.cinema.facilities.join(', '),
                  icon: Icons.local_activity,
                ),
              ],
            ),
          ),
          crossFadeState: _tabController.index == 0
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFF090909), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class ContainerWithBackground extends StatelessWidget {
  final Widget child;
  const ContainerWithBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
