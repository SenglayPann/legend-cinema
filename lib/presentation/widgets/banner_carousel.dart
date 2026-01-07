import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/movie_model.dart';
import '../screens/trailer/trailer_player_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'cinema_dropdown_selector.dart';

class BannerCarousel extends StatefulWidget {
  final List<MovieModel> banners;

  final String selectedCinema;
  final VoidCallback onCinemaTap;

  const BannerCarousel({
    super.key,
    required this.banners,
    required this.selectedCinema,
    required this.onCinemaTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }
    final MovieModel currentMovie = widget.banners[_currentIndex];
    final String backdropImage = currentMovie
        .posterUrl; // Use poster as backdrop if no specific backdrop url

    return Stack(
      children: [
        // -------- BLURRED BACKGROUND --------
        // -------- BLURRED BACKGROUND --------
        SizedBox(
          width: double.infinity,
          height: 820,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: CachedNetworkImage(
                  key: ValueKey(backdropImage),
                  imageUrl: backdropImage,
                  fit: BoxFit.cover,
                  height: 820,
                  width: double.infinity,
                  errorWidget: (_, __, ___) => Container(color: Colors.black),
                  placeholder: (_, __) => Container(color: Colors.black),
                ),
              ),
              // blur overlay
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  color: Colors.black.withOpacity(0.35), // dim overlay
                ),
              ),
            ],
          ),
        ),

        // -------- FOREGROUND CONTENT --------
        Column(
          children: [
            SizedBox(height: 100),
            CinemaDropdownSelector(
              selectedCinema: widget.selectedCinema,
              onTap: widget.onCinemaTap,
            ),
            const SizedBox(height: 16),
            CarouselSlider.builder(
              itemCount: widget.banners.length,
              itemBuilder: (context, index, realIndex) {
                final movie = widget.banners[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8), // spacing
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TrailerPlayerScreen(trailerUrl: movie.trailerUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          // Banner Image
                          CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[900]),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Bottom gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.65),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Play button (Visual only, tap handled by parent)
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: .5, // Small white border
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.black.withOpacity(
                                    0.3,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Title + Buy Button
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'd MMM yyyy',
                                      ).format(movie.releaseDate.toDate()),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 8,
                                    ), // spacing between date and rating

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        movie.rating,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const _BuyButton(),
                        ],
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 620,
                viewportFraction: 0.9,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (i, _) => setState(() => _currentIndex = i),
              ),
            ),

            const SizedBox(height: 14),

            // -------- POSITION INDICATORS --------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (index) {
                bool isActive = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.red : Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            bottomLeft: Radius.circular(28),
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.ticket_fill, // This is the movie icon
              size: 18.0,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              "Buy Ticket",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
