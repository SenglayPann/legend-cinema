import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _selectedCinema = "All Cinemas";

  final List<String> banners = [
    "https://drive.usercontent.google.com/download?id=1ztoZ6bbMpDJktu1TbzKr2VCx0pDVyDKJ",
    "https://drive.usercontent.google.com/download?id=12NMWqbh1TUoKuIbP9e3Btk8cki8ovTqf",
    "https://drive.usercontent.google.com/download?id=1COV9Skff636oRdfwloS7hHU03ptZN5YO",
  ];

  final List<String> cinemaLocations = [
    'All Cinemas',
    'Legend Midtown Mall',
    'Legend Olympia',
    'Legend Meanchey',
    'Legend Eden Garden',
    'Legend Toul Kork',
    'Legend Exchange Square',
    'Legend City Mall',
    'Legend Heritage Walk',
    'Legend P.S. Mall',
  ];

  final List<Map<String, String>> nowShowing = const [
    {
      'title': 'Hotel 2005',
      'date': '24 Oct, 2025',
      'rating': 'G',
      'poster':
          'https://drive.usercontent.google.com/download?id=1ztoZ6bbMpDJktu1TbzKr2VCx0pDVyDKJ',
    },
    {
      'title': 'Panggilan dari Kubur',
      'date': '24 Oct, 2025',
      'rating': 'NC13',
      'poster':
          'https://drive.usercontent.google.com/download?id=12NMWqbh1TUoKuIbP9e3Btk8cki8ovTqf',
    },
    {
      'title': 'The Annivesary',
      'date': '29 Oct, 2025',
      'rating': 'PG13',
      'poster':
          'https://drive.usercontent.google.com/download?id=1COV9Skff636oRdfwloS7hHU03ptZN5YO',
    },
  ];
  final List<Map<String, String>> comingSoon = const [
    {
      'title': 'Malam Terlarang',
      'date': '27 Oct, 2025',
      'rating': 'R16',
      'poster':
          'https://drive.usercontent.google.com/download?id=1ztoZ6bbMpDJktu1TbzKr2VCx0pDVyDKJ',
    },
    {
      'title': 'The Reborn',
      'date': '29 Oct, 2025',
      'rating': 'R16',
      'poster':
          'https://drive.usercontent.google.com/download?id=12NMWqbh1TUoKuIbP9e3Btk8cki8ovTqf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final movies = _selectedTabIndex == 0 ? nowShowing : comingSoon;

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
