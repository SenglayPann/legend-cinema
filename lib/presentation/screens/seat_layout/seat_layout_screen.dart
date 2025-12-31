import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/hall_model.dart';
import '../../../data/models/showtime_model.dart';
import '../../../data/services/hall_service.dart';
import '../../state/seat_selection_state.dart';
import '../../widgets/seat_layout/auto_scrolling_carousel.dart';
import '../../widgets/seat_layout/booking_details_cart.dart';
import '../../widgets/seat_layout/seat_layout_bottom_bar.dart';
import '../../widgets/seat_layout/seat_widget.dart';
import '../../widgets/seat_layout/screen_indicator.dart';
import '../../widgets/seat_layout/selected_seats_section.dart';

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
                      child: AutoScrollingCarousel(
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
                      child: AutoScrollingCarousel(
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
            child: SelectedSeatsSection(selectedSeats: state.selectedSeats),
          );
        },
      ),
    );
  }

  Widget _buildSlideUpCart(BuildContext context, double bottomBarHeight) {
    return Consumer<SeatSelectionState>(
      builder: (context, state, _) {
        return BookingDetailsCart(
          isExpanded: _isCartExpanded,
          bottomBarHeight: bottomBarHeight,
          selectedSeats: state.selectedSeats,
          seatCountByType: state.seatCountByType,
          hall: _hall!,
          onClose: _toggleCartDetails,
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, double bottomBarHeight) {
    return Consumer<SeatSelectionState>(
      builder: (context, state, _) {
        return SeatLayoutBottomBar(
          selectedCount: state.selectedCount,
          totalPrice: state.totalPrice,
          isCartExpanded: _isCartExpanded,
          onToggleCart: _toggleCartDetails,
          onContinue: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Proceeding with ${state.selectedCount} seats for \$${state.totalPrice.toStringAsFixed(2)}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
