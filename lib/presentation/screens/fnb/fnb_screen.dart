import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_scaffold.dart';

import 'dart:ui'; // Add this import

class FnBScreen extends StatefulWidget {
  const FnBScreen({super.key});

  @override
  State<FnBScreen> createState() => _FnBScreenState();
}

class _FnBScreenState extends State<FnBScreen> {
  // Mock data based on provided JSON
  final List<Map<String, String>> _cinemas = [
    {
      'name': 'Legend Cinema – Sihanoukville',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=10Pv6_ngxY3nIWGsSAB-F-ufvE_7rMB5u',
    },
    {
      'name': 'Legend Cinema – Noro Mall',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1c5JjqdltkctBeVxqBp1caXZujwTFbGsO',
    },
    {
      'name': 'Legend Cinema – Siem Reap',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1pGZw2vDWEDF_F9E68IgdxSyu-8ICkyZr',
    },
    {
      'name': 'Legend Cinema – K Mall',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1tLqFPs7lvvWndK_rRXG1vXj3JzSfjTVI',
    },
    {
      'name': 'Legend Cinema – City Mall',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=13l8tpSMCqALglHZLHKu65R6x5ThEPdPH',
    },
    {
      'name': 'Legend Cinema – Olympia Mall',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1CML8QzzMRrrsHcJeXQtFVeMa58XMyPRa',
    },
    {
      'name': 'Legend Premium Cinema – Exchange Square',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1kKfBM0-fMsmjqKs50VJnAPznBCak48y7',
    },
    {
      'name': 'Legend Cinema – Toul Kork',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=13l8tpSMCqALglHZLHKu65R6x5ThEPdPH',
    },
    {
      'name': 'Legend Cinema – Meanchey',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1Xu3GJacjW5A_AxwI2FxF9NrSJew2hj4v',
    },
    {
      'name': 'Legend Cinema – Midtown Mall',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1tLqFPs7lvvWndK_rRXG1vXj3JzSfjTVI',
    },
    {
      'name': 'Legend Cinema – SenSok',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1tLqFPs7lvvWndK_rRXG1vXj3JzSfjTVI',
    },
    {
      'name': 'Legend Cinema – Eden Garden',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1tLqFPs7lvvWndK_rRXG1vXj3JzSfjTVI',
    },
    {
      'name': 'Legend Cinema – 271 Mega Mall',
      'imageUrl':
          'https://drive.usercontent.google.com/download?id=1CML8QzzMRrrsHcJeXQtFVeMa58XMyPRa',
    },
  ];

  final String _bannerImage =
      'https://drive.google.com/uc?export=view&id=1X10FJAXsYgNxRj9XOt2tOtlzCJrbIjus';

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
            child: Image.network(_bannerImage, fit: BoxFit.cover),
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
            child: ListView.builder(
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
                          image: DecorationImage(
                            image: NetworkImage(_bannerImage),
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                          ),
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
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: AspectRatio(
                    aspectRatio: 6 / 1, // Taller ratio (was 10:1)
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // Glass effect background
                        color: Colors.white.withOpacity(0.1),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.15), // Reflection start
                            Colors.white.withOpacity(0.05), // Reflection end
                          ],
                          stops: const [0.0, 0.4], // Light reflection from left
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Rounded Square Image
                          AspectRatio(
                            aspectRatio: 1, // Square image
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Rounded corners
                                image: DecorationImage(
                                  image: NetworkImage(cinema['imageUrl']!),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
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
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  cinema['name']!,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
