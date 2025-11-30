import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PromotionCard extends StatelessWidget {
  final String imageUrl;
  final String description;
  final VoidCallback? onTap;

  const PromotionCard({
    super.key,
    required this.imageUrl,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            /// Background image
            Expanded(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),

            /// Bottom description box
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white.withOpacity(0.9),
              width: double.infinity, // Ensure it spans the width
              height: 50,
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
