import 'package:flutter/material.dart';
import '../../data/models/fnb_model.dart';
import 'quantity_control_buttons.dart';

class FnbItemCard extends StatelessWidget {
  final FnbModel item;
  final bool transparentQuantityButtons;

  const FnbItemCard({
    super.key,
    required this.item,
    this.transparentQuantityButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
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
            child: QuantityControlButtons(
              item: item,
              transparentBackground: transparentQuantityButtons,
            ),
          ),
        ],
      ),
    );
  }
}
