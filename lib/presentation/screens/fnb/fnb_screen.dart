import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_scaffold.dart';

import 'dart:ui'; // Add this import

import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/cinema_model.dart';
import '../../../data/services/cinema_service.dart';
import '../../widgets/glass_container.dart';
import 'fnb_order_screen.dart';

class FnBScreen extends StatefulWidget {
  const FnBScreen({super.key});

  @override
  State<FnBScreen> createState() => _FnBScreenState();
}

class _FnBScreenState extends State<FnBScreen> {
  final CinemaService _cinemaService = CinemaService();
  List<CinemaModel> _cinemas = [];
  bool _isLoading = true;

  final String _bannerImage =
      'https://lh3.googleusercontent.com/d/1X10FJAXsYgNxRj9XOt2tOtlzCJrbIjus';

  @override
  void initState() {
    super.initState();
    _fetchCinemas();
  }

  Future<void> _fetchCinemas() async {
    try {
      final cinemas = await _cinemaService.getCinemas();
      if (mounted) {
        setState(() {
          _cinemas = cinemas;
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      showBackButton: false,
      title: 'F&B',
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _bannerImage,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.black),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.6), // Dark overlay
              ),
            ),
          ),

          // Content
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                : ListView.builder(
                    itemCount: _cinemas.length + 1, // +1 for banner/header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Header Section: Banner + Title
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Banner
                            Container(
                              height: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                              ),
                              child: CachedNetworkImage(
                                imageUrl: _bannerImage,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.centerRight,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            // Title
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12,
                              ),
                              child: const Text(
                                "Choose Cinema",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final cinema = _cinemas[index - 1];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FnbOrderScreen(cinema: cinema),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: AspectRatio(
                            aspectRatio: 6 / 1, // Taller ratio (was 10:1)
                            child: GlassContainer(
                              borderRadius: BorderRadius.circular(12),
                              borderWidth: 0.5,
                              borderGradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(
                                    0.5,
                                  ), // Reflection start (increased opacity for visibility)
                                  Colors.white.withOpacity(
                                    0.1,
                                  ), // Reflection end
                                ],
                                stops: const [
                                  0.0,
                                  0.8,
                                ], // Light reflection from left
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Rounded Square Image
                                  AspectRatio(
                                    aspectRatio: 1, // Square image
                                    child: CachedNetworkImage(
                                      imageUrl: cinema.imageUrl,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.error,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Aligned Top Cinema Name
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          cinema.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Right Arrow Icon
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
