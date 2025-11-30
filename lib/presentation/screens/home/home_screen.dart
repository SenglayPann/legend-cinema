import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/models/cinema_model.dart';
import '../../../data/services/movie_service.dart';
import '../../../data/services/cinema_service.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/services/offer_service.dart';
import '../../widgets/movie_tabs.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/cinema_selector_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  late ScrollController _scrollController;
  final ValueNotifier<bool> _isScrolledNotifier = ValueNotifier(false);
  final MovieService _movieService = MovieService();
  final CinemaService _cinemaService = CinemaService();
  final OfferService _offerService = OfferService();

  List<MovieModel> banners = [];
  List<CinemaModel> cinemaLocations = [];
  List<MovieModel> nowShowing = [];
  List<MovieModel> comingSoon = [];
  List<OfferModel> offers = [];
  bool isLoading = true;

  String _selectedCinema = "All Cinemas";

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset > 0 && !_isScrolledNotifier.value) {
          _isScrolledNotifier.value = true;
        } else if (_scrollController.offset <= 0 && _isScrolledNotifier.value) {
          _isScrolledNotifier.value = false;
        }
      });
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final fetchedBanners = await _movieService.getBanners();
      final fetchedCinemas = await _cinemaService.getCinemas();
      final fetchedNowShowing = await _movieService.getNowShowingMovies();
      final fetchedComingSoon = await _movieService.getComingSoonMovies();
      final fetchedOffers = await _offerService.getOffers();

      if (mounted) {
        setState(() {
          banners = fetchedBanners;
          cinemaLocations = fetchedCinemas;
          nowShowing = fetchedNowShowing;
          comingSoon = fetchedComingSoon;
          offers = fetchedOffers;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching home data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 11, 11, 11),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 11, 11),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: HomeAppBar(isScrolledListenable: _isScrolledNotifier),
      ),

      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BannerCarousel(
              banners: banners,
              selectedCinema: _selectedCinema,
              onCinemaTap: () {
                _openCinemaSelector(context);
              },
            ),

            const SizedBox(height: 14),

            MovieTabs(
              nowShowing: nowShowing,
              comingSoon: comingSoon,
              offers: offers,
              selectedTabIndex: _selectedTabIndex,
              onTabChanged: (i) => setState(() => _selectedTabIndex = i),
            ),
            const SizedBox(height: 16),

            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 5 / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://drive.google.com/uc?export=view&id=17H44tOWhHxL1dtTbpGu7GUeHpA_mxLRT',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.9), // Darker gradient
                          Colors.transparent,
                        ],
                        stops: const [
                          0.0,
                          0.5, // Extend the darker part further down
                          0.9, // Make the transparent part start later
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Want to watch your favorite movie at nearby cinema? Explore now to see more cinema around you",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement navigation or action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            "Explore more",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16, // Bigger text
                              fontWeight: FontWeight.bold, // Bolder text
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  void _openCinemaSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CinemaSelectorDialog(
        cinemas: cinemaLocations,
        currentSelection: _selectedCinema,
        onSelected: (cinema) {
          setState(() => _selectedCinema = cinema);
        },
      ),
    );
  }
}
