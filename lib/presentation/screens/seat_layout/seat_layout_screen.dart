import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/hall_model.dart';
import '../../../data/models/showtime_model.dart';
import '../../../data/services/hall_service.dart';
import '../../state/seat_selection_state.dart';
import '../../widgets/seat_layout/seat_widget.dart';
import '../../widgets/seat_layout/screen_indicator.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_divider.dart';
import '../../widgets/custom_button.dart';

class SeatLayoutScreen extends StatefulWidget {
  final ShowtimeModel showtime;

  const SeatLayoutScreen({super.key, required this.showtime});

  @override
  State<SeatLayoutScreen> createState() => _SeatLayoutScreenState();
}

class _SeatLayoutScreenState extends State<SeatLayoutScreen>
    with _SeatLayoutBuilders {
  final HallService _hallService = HallService();
  HallModel? _hall;
  bool _isLoading = true;
  bool _isCartExpanded = false;

  @override
  void initState() {
    print("showtimeId: " + widget.showtime.id.toString());
    super.initState();
    _loadHall();
  }

  Future<void> _loadHall() async {
    print("hallId: " + widget.showtime.hallId.toString());
    final hall = await _hallService.getHallById(widget.showtime.hallId);
    if (mounted) {
      setState(() {
        _hall = hall;
        _isLoading = false;
      });
    }
  }

  void _toggleCartDetails() {
    setState(() {
      _isCartExpanded = !_isCartExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF090909),
        body: const Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (_hall == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF090909),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Hall not found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) =>
          SeatSelectionState(showtime: widget.showtime, hall: _hall!),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final bottomBarHeight = 60 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Stack(
        children: [
          // Background with blur
          Positioned.fill(
            child: widget.showtime.moviePosterUrl.isNotEmpty
                ? Image.network(
                    widget.showtime.moviePosterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.black),
                  )
                : Container(color: Colors.black),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.black.withOpacity(0.75)),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Seat Layout
                Expanded(
                  child: Consumer<SeatSelectionState>(
                    builder: (context, state, _) {
                      // Show loading while fetching booked seats
                      if (state.isLoading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                'Loading seats...',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }
                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 2.5,
                        boundaryMargin: const EdgeInsets.all(100),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom: bottomBarHeight + 20,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              const ScreenIndicator(),
                              const SizedBox(height: 16),
                              _buildSeatLayout(state),
                              const SizedBox(height: 200),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Scrim for cart
          if (_isCartExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleCartDetails,
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),

          // Selected Seats Section (positioned above bottom bar)
          _buildSelectedSeatsPositioned(context, bottomBarHeight),

          // Slide-up cart details (on top of selected seats)
          _buildSlideUpCart(context, bottomBarHeight),

          // Bottom bar
          _buildBottomBar(context, bottomBarHeight),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // Movie info container - expands to timer
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0.0, 0.9, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Movie title carousel
                    SizedBox(
                      height: 20,
                      child: _AutoScrollingCarousel(
                        items: [widget.showtime.movieTitle],
                        separator: '',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Info carousel
                    SizedBox(
                      height: 18,
                      child: _AutoScrollingCarousel(
                        items: [
                          widget.showtime.showDate,
                          widget.showtime.showTime,
                          'Hall ${widget.showtime.hallNumber}',
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Countdown timer
          Consumer<SeatSelectionState>(
            builder: (context, state, _) {
              final isLow = state.remainingSeconds <= 30;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isLow
                      ? Colors.red.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: isLow ? Colors.red : Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.formattedCountdown,
                      style: TextStyle(
                        color: isLow ? Colors.red : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // _SeatLayoutScreenState methods continue after carousel widget
}

/// Auto-scrolling carousel widget - scrolls one round, pauses 5 seconds, loops infinitely
class _AutoScrollingCarousel extends StatefulWidget {
  final List<String> items;
  final String separator;
  final TextStyle? textStyle;
  final TextStyle? separatorStyle;

  const _AutoScrollingCarousel({
    required this.items,
    this.separator = ' | ',
    this.textStyle,
    this.separatorStyle,
  });

  @override
  State<_AutoScrollingCarousel> createState() => _AutoScrollingCarouselState();
}

class _AutoScrollingCarouselState extends State<_AutoScrollingCarousel> {
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
    final spacer = '  ';
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

// Mixin containing seat layout building methods
mixin _SeatLayoutBuilders on State<SeatLayoutScreen> {
  HallModel? get _hall;
  bool get _isCartExpanded;
  void _toggleCartDetails();

  Widget _buildSeatLayout(SeatSelectionState state) {
    final standardColumns = state.regularSeats.isEmpty
        ? 0
        : state.regularSeats
              .map((row) => row.length)
              .reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic seat size based on available width and standard section columns
        final rowLabelWidth = 40.0;
        final availableWidth = constraints.maxWidth - rowLabelWidth;
        final seatMarginTotal = 4.0;
        final maxSeatSize = 28.0;
        final minSeatSize = 16.0;

        double calculatedSize = standardColumns > 0
            ? (availableWidth / standardColumns) - seatMarginTotal
            : maxSeatSize;

        final seatSize = calculatedSize.clamp(minSeatSize, maxSeatSize);

        return Column(
          children: [
            // Regular seats
            if (state.regularSeats.isNotEmpty) ...[
              _buildSeatSection(
                'Standard',
                state.regularSeats,
                state,
                seatSize,
              ),
              const SizedBox(height: 16),
            ],

            // VIP seats
            if (state.vipSeats.isNotEmpty) ...[
              _buildSeatSection('VIP', state.vipSeats, state, seatSize),
              const SizedBox(height: 16),
            ],

            // Twin seats
            if (state.twinSeats.isNotEmpty)
              _buildSeatSection('Twin', state.twinSeats, state, seatSize),
          ],
        );
      },
    );
  }

  Widget _buildSeatSection(
    String label,
    List<List<Seat>> seats,
    SeatSelectionState state,
    double seatSize,
  ) {
    final isTwin = label == 'Twin';

    return Column(
      children: [
        // Seat rows
        ...seats.map(
          (row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row label
              SizedBox(
                width: 20,
                child: Text(
                  row.isNotEmpty ? row.first.row : '',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              // Seats with gaps for twin seats
              ...row.asMap().entries.expand((entry) {
                final index = entry.key;
                final seat = entry.value;
                final widgets = <Widget>[
                  SeatWidget(
                    seat: seat,
                    onTap: () => state.toggleSeat(seat),
                    size: seatSize,
                  ),
                ];
                // Add gap after every 2nd twin seat (pairs)
                if (isTwin && (index + 1) % 2 == 0 && index < row.length - 1) {
                  widgets.add(SizedBox(width: seatSize));
                }
                return widgets;
              }),
              // Row label (right side)
              SizedBox(
                width: 20,
                child: Text(
                  row.isNotEmpty ? row.first.row : '',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSeatsPositioned(
    BuildContext context,
    double bottomBarHeight,
  ) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomBarHeight,
      child: Consumer<SeatSelectionState>(
        builder: (context, state, _) {
          return Container(
            color: Colors.transparent,
            child: _buildSelectedSeatsSection(state),
          );
        },
      ),
    );
  }

  Widget _buildSelectedSeatsSection(SeatSelectionState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Seats title
          const Text(
            'Selected Seats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Selected seats list
          if (state.selectedSeats.isEmpty)
            const Text(
              'Tap on seats to select',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: state.selectedSeats.map((seat) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    seat.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          // Divider
          const GradientDivider(),
          const SizedBox(height: 12),
          // Seat types and prices
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSeatTypePrice('Standard', '\$8', Colors.white70),
                _buildSeatTypePrice('VIP', '\$12', Colors.amber),
                _buildSeatTypePrice('Twin', '\$20', Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          const GradientDivider(),
        ],
      ),
    );
  }

  Widget _buildSeatTypePrice(String type, String price, Color color) {
    return Column(
      children: [
        Text(
          type,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          price,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSlideUpCart(BuildContext context, double bottomBarHeight) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: _isCartExpanded ? 0 : -MediaQuery.of(context).size.height,
      child: Consumer<SeatSelectionState>(
        builder: (context, state, _) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomBarHeight + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Booking Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GlassContainer(
                        width: 32,
                        height: 32,
                        padding: EdgeInsets.zero,
                        borderRadius: BorderRadius.circular(16),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _toggleCartDetails,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const GradientDivider(),
                  const SizedBox(height: 16),

                  // Selected seats section
                  const Text(
                    'Selected Seats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.selectedSeats.isEmpty)
                    const Text(
                      'No seats selected',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.selectedSeats.map((seat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            seat.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  const GradientDivider(),
                  const SizedBox(height: 16),

                  // Price breakdown
                  const Text(
                    'Price Breakdown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    'Standard',
                    state.seatCountByType[SeatType.regular] ?? 0,
                    _hall!.seatPrice,
                  ),
                  _buildPriceRow(
                    'VIP',
                    state.seatCountByType[SeatType.vip] ?? 0,
                    _hall!.vipSeatPrice,
                  ),
                  _buildPriceRow(
                    'Twin',
                    state.seatCountByType[SeatType.twin] ?? 0,
                    _hall!.twinSeatPrice,
                  ),
                  const SizedBox(height: 16),
                  const GradientDivider(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceRow(String type, int count, double price) {
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$type x$count', style: const TextStyle(color: Colors.white70)),
          Text(
            '\$${(count * price).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double bottomBarHeight) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Consumer<SeatSelectionState>(
        builder: (context, state, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom bar content (with black background extending to bottom)
              Container(
                color: Colors.black,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Summary section
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    state.selectedCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Summary',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '\$${state.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _toggleCartDetails,
                              child: Icon(
                                _isCartExpanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        // Continue button
                        CustomButton(
                          text: 'Continue',
                          onPressed: state.selectedCount > 0
                              ? () {
                                  // TODO: Navigate to checkout/summary
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Proceeding with ${state.selectedCount} seats for \$${state.totalPrice.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  );
                                }
                              : () {},
                          width: 140,
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
