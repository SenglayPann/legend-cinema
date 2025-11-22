import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final ValueListenable<bool> isScrolledListenable;

  const HomeAppBar({super.key, required this.isScrolledListenable});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isScrolledListenable,
      builder: (context, isScrolled, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: Colors.black.withOpacity(isScrolled ? 1.0 : 0.0),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: child,
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: SizedBox(
              height: 55,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      "lib/assets/images/legend_cinema_logo_crop.png",
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.notifications_none, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
