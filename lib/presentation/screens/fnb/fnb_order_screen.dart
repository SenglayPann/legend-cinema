import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/cinema_model.dart';
import '../../../data/models/fnb_model.dart';
import '../../../data/services/fnb_service.dart';
import '../../state/cart_state.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/gradient_divider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_button.dart';
import 'fnb_order_summary_screen.dart';

class FnbOrderScreen extends StatefulWidget {
  final CinemaModel cinema;

  const FnbOrderScreen({super.key, required this.cinema});

  @override
  State<FnbOrderScreen> createState() => _FnbOrderScreenState();
}

class _FnbOrderScreenState extends State<FnbOrderScreen> {
  final FnbService _fnbService = FnbService();
  List<FnbModel> _fnbItems = [];
  bool _isLoading = true;
  bool _isCartExpanded = false;

  final String _bannerImage =
      'https://lh3.googleusercontent.com/d/1X10FJAXsYgNxRj9XOt2tOtlzCJrbIjus';

  @override
  void initState() {
    super.initState();
    _fetchFnbItems();
  }

  Future<void> _fetchFnbItems() async {
    final items = await _fnbService.getFnbItems();
    // Sort by name
    items.sort((a, b) => a.name.compareTo(b.name));
    if (mounted) {
      setState(() {
        _fnbItems = items;
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
    // Estimate bottom bar height + safe area
    final bottomBarHeight = 50 + MediaQuery.of(context).padding.bottom;

    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      showBackButton: true,
      title: 'F&B',
      body: Stack(
        children: [
          // Background Image with Blur (using cinema image)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.cinema.imageUrl,
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
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            bottom:
                                bottomBarHeight + 20, // Space for bottom bar
                          ),
                          itemCount: _fnbItems.length + 1, // +1 for banner
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Header Section: Banner + Title
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Banner
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      image: DecorationImage(
                                        image: NetworkImage(_bannerImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      imageUrl: _bannerImage,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.centerRight,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  // Title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: const Text(
                                      "Choose F&B",
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

                            final item = _fnbItems[index - 1];
                            return GlassContainer(
                              margin: const EdgeInsets.only(
                                bottom: 16,
                                left: 16,
                                right: 16,
                              ),
                              padding: const EdgeInsets.all(12),
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image (x2 scale relative to previous small icon)
                                      Container(
                                        width: 80, // Increased size
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(item.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Details
                                      Expanded(
                                        child: SizedBox(
                                          height: 80,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "\$${item.price.toStringAsFixed(2)}",
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
                                    child: Consumer<CartState>(
                                      builder: (context, cart, child) {
                                        final cartItem = cart.items[item.id];
                                        final quantity =
                                            cartItem?.quantity ?? 0;

                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE50914),
                                            ),
                                            child: quantity == 0
                                                ? InkWell(
                                                    onTap: () =>
                                                        cart.addItem(item),
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      alignment:
                                                          Alignment.center,
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
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                          onTap: () => cart
                                                              .removeItem(item),
                                                          child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            alignment: Alignment
                                                                .center,
                                                            child: const Icon(
                                                              Icons.remove,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 4,
                                                              ),
                                                          child: Text(
                                                            '$quantity',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 11,
                                                                ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () => cart
                                                              .addItem(item),
                                                          child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            alignment: Alignment
                                                                .center,
                                                            child: const Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
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
                          },
                        ),
                ),
              ],
            ),
          ),

          // Scrim (Dark overlay when cart is expanded)
          if (_isCartExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleCartDetails,
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),

          // Slide-up Cart Details (Behind Bottom Bar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isCartExpanded
                ? 0
                : -MediaQuery.of(context).size.height, // Hide below screen
            child: Consumer<CartState>(
              builder: (context, cart, child) {
                return Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: bottomBarHeight + 16, // Padding for bottom bar
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Booking Details",
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
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleCartDetails,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Gradient Divider
                        const GradientDivider(),

                        const SizedBox(height: 16),

                        const Text(
                          "F&B",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (cart.items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Your cart is empty",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cart.items.values.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.item.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "\$${item.totalPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 16),

                        // Gradient Divider at the end
                        const GradientDivider(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Bar (Fixed)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<CartState>(
              builder: (context, cart, child) {
                int totalItems = 0;
                for (var item in cart.items.values) {
                  totalItems += item.quantity;
                }

                return Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Summary Section
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

                                // Your text on top of the icon
                                Container(
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    totalItems.toString(),
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
                                  "Summary",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "\$${cart.totalAmount.toStringAsFixed(2)}",
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

                        // Continue Button
                        CustomButton(
                          text: "Continue",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FnbOrderSummaryScreen(
                                  cinema: widget.cinema,
                                ),
                              ),
                            );
                          },
                          width: 140,
                          height: 48,
                        ),
                      ],
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
