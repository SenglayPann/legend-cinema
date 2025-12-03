import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/fnb_model.dart';
import '../state/cart_state.dart';

class QuantityControlButtons extends StatelessWidget {
  final FnbModel item;
  final bool transparentBackground;

  const QuantityControlButtons({
    super.key,
    required this.item,
    this.transparentBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (context, cart, child) {
        final cartItem = cart.items[item.id];
        final quantity = cartItem?.quantity ?? 0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: transparentBackground
                  ? Colors.transparent
                  : const Color(0xFFE50914),
              border: transparentBackground
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: quantity == 0
                ? InkWell(
                    onTap: () => cart.addItem(item),
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
                          onTap: () => cart.removeItem(item),
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
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => cart.addItem(item),
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
        );
      },
    );
  }
}
