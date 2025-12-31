import 'dart:async';
import 'package:flutter/material.dart';

/// Auto-scrolling carousel widget - scrolls one round, pauses 5 seconds, loops infinitely
class AutoScrollingCarousel extends StatefulWidget {
  final List<String> items;
  final String separator;
  final TextStyle? textStyle;
  final TextStyle? separatorStyle;

  const AutoScrollingCarousel({
    super.key,
    required this.items,
    this.separator = ' | ',
    this.textStyle,
    this.separatorStyle,
  });

  @override
  State<AutoScrollingCarousel> createState() => _AutoScrollingCarouselState();
}

class _AutoScrollingCarouselState extends State<AutoScrollingCarousel> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrollCycle();
    });
  }

  void _startScrollCycle() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return; // Content fits, no scrolling needed

    // Scroll from start to end
    _scrollController.jumpTo(0);
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || !_scrollController.hasClients) {
        timer.cancel();
        return;
      }

      final current = _scrollController.offset;
      if (current >= maxScroll) {
        timer.cancel();
        // Pause 5 seconds at end, then restart
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) _startScrollCycle();
        });
      } else {
        _scrollController.jumpTo(current + 0.8);
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    // Build content string with separators
    final content = widget.items.join(widget.separator);
    // Duplicate content with spacing for seamless infinite scroll
    const spacer = '  ';
    final duplicatedContent = '$content$spacer$content$spacer$content$spacer';

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        duplicatedContent,
        style: widget.textStyle ?? defaultTextStyle,
        maxLines: 1,
      ),
    );
  }
}
