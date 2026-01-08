import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:legend_cinema/data/models/movie_model.dart';
import 'package:legend_cinema/data/services/movie_service.dart';
import 'package:legend_cinema/presentation/widgets/app_scaffold.dart';
import 'package:legend_cinema/presentation/widgets/shared/movie_card.dart';
import 'package:legend_cinema/presentation/screens/movie_detail/movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MovieService _movieService = MovieService();

  List<MovieModel> _allMovies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchMovies() async {
    try {
      // Fetch both Now Showing and Coming Soon
      final nowShowing = await _movieService.getNowShowingMovies();
      final comingSoon = await _movieService.getComingSoonMovies();

      // Combine and remove duplicates if any (though usually distinct status)
      final all = [...nowShowing, ...comingSoon];
      // Deduplicate by ID just in case
      final uniqueMovies = <String, MovieModel>{};
      for (var m in all) {
        uniqueMovies[m.id] = m;
      }

      if (mounted) {
        setState(() {
          _allMovies = uniqueMovies.values.toList();
          _filteredMovies = _allMovies;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching movies for search: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMovies = _allMovies;
      } else {
        _filteredMovies = _allMovies.where((movie) {
          return movie.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      showBackButton: true,
      title: 'search_title'.tr(),
      // title: 'Search', // We'll use custom title in body or just app bar title
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr(),
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1C1C1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    )
                  : _filteredMovies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "no_movies_found".tr(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = _filteredMovies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(
                                  movieId: movie.id,
                                  cinemaName: 'All Cinemas', // Default context
                                ),
                              ),
                            );
                          },
                          child: MovieCard(
                            movie: movie,
                            isComingSoon: movie.status == 'upcoming',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
