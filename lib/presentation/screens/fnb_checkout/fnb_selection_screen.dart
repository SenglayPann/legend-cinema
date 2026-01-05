import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/fnb_model.dart';
import '../../../data/models/showtime_model.dart';
import '../../../data/services/fnb_service.dart';
import '../../state/seat_selection_state.dart';
import '../../widgets/seat_layout/auto_scrolling_carousel.dart';
import '../../widgets/seat_layout/booking_details_cart.dart';
import '../../widgets/seat_layout/seat_layout_bottom_bar.dart';
import '../../widgets/glass_container.dart';
import 'order_detail_screen.dart';

class FnbSelectionScreen extends StatefulWidget {
  final ShowtimeModel showtime;

  const FnbSelectionScreen({super.key, required this.showtime});

  @override
  State<FnbSelectionScreen> createState() => _FnbSelectionScreenState();
}

class _FnbSelectionScreenState extends State<FnbSelectionScreen> {
  final FnbService _fnbService = FnbService();
  List<FnbModel> _fnbItems = [];
  bool _isLoading = true;
  bool _isCartExpanded = false;

  void _toggleCartDetails() {
    setState(() {
      _isCartExpanded = !_isCartExpanded;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFnbItems();
  }

  Future<void> _fetchFnbItems() async {
    final items = await _fnbService.getFnbItems();
    items.sort((a, b) => a.name.compareTo(b.name));
    if (mounted) {
      setState(() {
        _fnbItems = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomBarHeight = 70 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Stack(
        children: [
          // Background Image with Blur (using movie poster)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.showtime.moviePosterUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.black),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header (same as seat layout)
                _buildHeader(context),
                const SizedBox(height: 16),

                // FnB List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        )
                      : _buildFnbList(),
                ),
              ],
            ),
          ),
          // Slide-up cart (booking details)
          _buildSlideUpCart(context, bottomBarHeight),

          // Bottom bar
          _buildBottomBar(context, bottomBarHeight),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GlassContainer(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(12),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),

          // Movie info
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.85, 1.0],
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
              return GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: state.remainingSeconds <= 30
                          ? Colors.red
                          : Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.formattedCountdown,
                      style: TextStyle(
                        color: state.remainingSeconds <= 30
                            ? Colors.red
                            : Colors.white,
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

  Widget _buildFnbList() {
    return Consumer<SeatSelectionState>(
      builder: (context, state, _) {
        return ListView.builder(
          padding: EdgeInsets.only(
            bottom: 100 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: _fnbItems.length,
          itemBuilder: (context, index) {
            final item = _fnbItems[index];
            final quantity = state.getFnbQuantity(item.id);
            return _buildFnbCard(item, quantity, state);
          },
        );
      },
    );
  }

  Widget _buildFnbCard(FnbModel item, int quantity, SeatSelectionState state) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: Icon(Icons.fastfood, color: Colors.white54),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.fastfood, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Add/Remove Button
          Positioned(
            bottom: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFE50914)),
                child: quantity == 0
                    ? InkWell(
                        onTap: () => state.addFnbItem(item),
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 24,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => state.removeFnbItem(item.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => state.addFnbItem(item),
                              child: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double bottomBarHeight) {
    return Consumer<SeatSelectionState>(
      builder: (context, state, _) {
        return SeatLayoutBottomBar(
          selectedCount: state.selectedCount,
          totalPrice: state.grandTotal,
          isCartExpanded: _isCartExpanded,
          onToggleCart: _toggleCartDetails,
          buttonText: state.hasFnbItems ? 'Continue' : 'Skip',
          onContinue: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: state,
                  child: OrderDetailScreen(showtime: widget.showtime),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSlideUpCart(BuildContext context, double bottomBarHeight) {
    return Consumer<SeatSelectionState>(
      builder: (context, state, _) {
        final hall = context.read<SeatSelectionState>().hall;
        return BookingDetailsCart(
          isExpanded: _isCartExpanded,
          bottomBarHeight: bottomBarHeight,
          selectedSeats: state.selectedSeats,
          seatCountByType: state.seatCountByType,
          hall: hall,
          fnbItems: state.fnbItems,
          fnbQuantities: state.fnbQuantities,
          onClose: _toggleCartDetails,
        );
      },
    );
  }
}
