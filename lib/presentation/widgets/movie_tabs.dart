import 'package:flutter/material.dart';
import './movie_grid.dart';
import '../widgets/tab_selector.dart';

class MovieTabs extends StatelessWidget {
  final List<Map<String, String>> nowShowing;
  final List<Map<String, String>> comingSoon;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;

  const MovieTabs({
    super.key,
    required this.nowShowing,
    required this.comingSoon,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isComingSoon = selectedTabIndex == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// -------------------------------
        /// CUSTOM TAB SELECTOR
        /// -------------------------------
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabSelector(
              selectedIndex: selectedTabIndex,
              onChanged: onTabChanged,
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// -------------------------------
        /// STACK WITH FADE TRANSITION
        /// -------------------------------
        Stack(
          alignment: Alignment.topCenter,
          children: [
            // Now Showing
            AnimatedOpacity(
              opacity: isComingSoon ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: isComingSoon,
                child:
                    isComingSoon // Make height 0 when disabled
                    ? const SizedBox.shrink()
                    : MovieGrid(movies: nowShowing, isComingSoon: false),
              ),
            ),

            // Coming Soon
            AnimatedOpacity(
              opacity: isComingSoon ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !isComingSoon,
                child:
                    !isComingSoon // Make height 0 when disabled
                    ? const SizedBox.shrink()
                    : MovieGrid(movies: comingSoon, isComingSoon: true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
