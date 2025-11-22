import 'package:flutter/material.dart';
import 'package:legend_cinema/presentation/widgets/shared/promotion_card.dart';
import 'package:legend_cinema/presentation/widgets/shared/movie_card.dart';
import './date_bar.dart';

class MovieGrid extends StatelessWidget {
  final List<Map<String, String>> movies;
  final bool isComingSoon;

  const MovieGrid({
    super.key,
    required this.movies,
    required this.isComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateBar(isNowShowing: !isComingSoon),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            isComingSoon ? "Coming Soon" : "Now Showing",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (_, i) =>
              MovieCard(movie: movies[i], isComingSoon: isComingSoon),
        ),

        const SizedBox(height: 24),

        /// ----------------------------------------------------
        ///  HORIZONTAL PROMO LIST (Only when NOW SHOWING)
        /// ----------------------------------------------------
        if (!isComingSoon)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Promotions",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement navigation to promotions list
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (!isComingSoon) const SizedBox(height: 12),

        if (!isComingSoon)
          SizedBox(
            height: 230, // controls promo card size (required)
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: promoItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => SizedBox(
                width: 320, // width for 4:3 ratio (4 wide : 3 tall)
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: PromotionCard(
                    imageUrl: promoItems[i],
                    description: "Buy 1 Free 1 – Today Only!",
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }
}

/// Dummy promo images — replace with your real promo data
final List<String> promoItems = [
  "https://drive.google.com/uc?export=view&id=1LWjgVwkLrjzJ0qjHwRXBEmS60L3_uIQc",
  "https://drive.google.com/uc?export=view&id=1_CFDFIEmdDw8dhUC7tGUNxUoiOUkYC8d",
  "https://drive.google.com/uc?export=view&id=1iBb3YOxLLZXzyX60Ka514KReYHDTzZeD",
  "https://drive.google.com/uc?export=view&id=1d0olAMXLZE8Wlhu0Hr7wWg3DixUOl5-f",
  "https://drive.google.com/uc?export=view&id=1w8XokFqASBsOF4cZ3jepUPQ-KpyZ-CMB",
];
