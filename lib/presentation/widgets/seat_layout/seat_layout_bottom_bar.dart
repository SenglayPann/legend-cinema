import 'package:flutter/material.dart';
import '../custom_button.dart';

/// Bottom bar with summary and continue button
class SeatLayoutBottomBar extends StatelessWidget {
  final int selectedCount;
  final double totalPrice;
  final bool isCartExpanded;
  final VoidCallback onToggleCart;
  final VoidCallback onContinue;
  final String buttonText;

  const SeatLayoutBottomBar({
    super.key,
    required this.selectedCount,
    required this.totalPrice,
    required this.isCartExpanded,
    required this.onToggleCart,
    required this.onContinue,
    this.buttonText = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
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
                                selectedCount.toString(),
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
                              '\$${totalPrice.toStringAsFixed(2)}',
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
                          onTap: onToggleCart,
                          child: Icon(
                            isCartExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    // Continue button
                    CustomButton(
                      text: buttonText,
                      onPressed: selectedCount > 0 ? onContinue : () {},
                      width: 140,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
