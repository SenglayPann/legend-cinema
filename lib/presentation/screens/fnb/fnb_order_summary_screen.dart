import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/cinema_model.dart';
import '../../state/cart_state.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_divider.dart';
import '../../widgets/custom_button.dart';

class FnbOrderSummaryScreen extends StatelessWidget {
  final CinemaModel cinema;

  const FnbOrderSummaryScreen({super.key, required this.cinema});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      showBackButton: true,
      title: 'Order Summary',
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: cinema.imageUrl,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Cinema Name Glass Box
                        GlassContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cinema.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // F&B Items Glass Box
                        Consumer<CartState>(
                          builder: (context, cart, child) {
                            final cartItems = cart.items.values.toList();

                            return GlassContainer(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'F&B Items',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Loop through cart items
                                  ...cartItems.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final cartItem = entry.value;
                                    final isLast =
                                        index == cartItems.length - 1;

                                    return Column(
                                      children: [
                                        // Item Row
                                        Stack(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Item Image
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        cartItem.item.imageUrl,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Item Details
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 60,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          cartItem.item.name,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        Text(
                                                          "\$${cartItem.item.price.toStringAsFixed(2)}",
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Quantity Controls - Positioned at bottom right
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    // border: Border.all(
                                                    //   color: Colors.white
                                                    //       .withOpacity(0.3),
                                                    //   width: 1,
                                                    // ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            cart.removeItem(
                                                              cartItem.item,
                                                            ),
                                                        child: Container(
                                                          width: 24,
                                                          height: 24,
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Icon(
                                                            Icons.remove,
                                                            color: Colors.white,
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
                                                          '${cartItem.quantity}',
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
                                                        onTap: () =>
                                                            cart.addItem(
                                                              cartItem.item,
                                                            ),
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
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Divider (not for last item)
                                        if (!isLast) ...[
                                          const SizedBox(height: 16),
                                          const GradientDivider(),
                                          const SizedBox(height: 16),
                                        ],
                                      ],
                                    );
                                  }).toList(),

                                  const SizedBox(height: 16),
                                  const GradientDivider(),
                                  const SizedBox(height: 16),

                                  // Total Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Checkout Button at Bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  text: 'Checkout',
                  onPressed: () {
                    // Handle checkout
                  },
                  height: 48,
                  borderRadius: 32,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
