import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_scaffold.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/cinema_model.dart';
import '../../../data/services/cinema_service.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CinemaService _cinemaService = CinemaService();
  List<CinemaModel> _allCinemas = [];
  List<CinemaModel> _filteredCinemas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCinemas();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCinemas() async {
    try {
      final cinemas = await _cinemaService.getCinemas();
      if (mounted) {
        setState(() {
          _allCinemas = cinemas;
          _filteredCinemas = cinemas;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cinemas: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCinemas = _allCinemas.where((cinema) {
        return cinema.name.toLowerCase().contains(query) ||
            cinema.city.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      showBackButton: false,
      title: 'Cinema',
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search cinema...',
                  hintStyle: const TextStyle(color: Colors.white),
                  suffixIcon: _searchController.text.isEmpty
                      ? const Icon(Icons.search, color: Colors.white54)
                      : IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            // FocusScope.of(context).unfocus(); // Optional: keep focus or not? Usually keep focus to type new query.
                          },
                        ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.white54,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.white54,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 0.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
              ),
            ),

            // Cinema List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    )
                  : _filteredCinemas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No cinemas found",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _filteredCinemas.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final cinema = _filteredCinemas[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF090909),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 0.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cinema Image (5:3 ratio)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: 5 / 3,
                                  child: CachedNetworkImage(
                                    imageUrl: cinema.imageUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.error,
                                            color: Colors.white,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              // Cinema Name and Location
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cinema.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          cinema.city,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
