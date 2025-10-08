import 'package:flutter/foundation.dart';
import '../../data/models/fnb_model.dart';

class CartItem {
  final FnbModel item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get totalPrice =>
      (item.discountPrice ?? item.price) * quantity;
}

class CartState extends ChangeNotifier {
  final Map<String, CartItem> _items = {}; // key: FnbModel.id

  Map<String, CartItem> get items => _items;

  double get totalAmount {
    double total = 0;
    for (final cartItem in _items.values) {
      total += cartItem.totalPrice;
    }
    return total;
  }

  /// Add or increase an item's quantity
  void addItem(FnbModel item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += 1;
    } else {
      _items[item.id] = CartItem(item: item);
    }
    notifyListeners();
  }

  /// Remove a single quantity of an item
  void removeItem(FnbModel item) {
    if (!_items.containsKey(item.id)) return;

    if (_items[item.id]!.quantity > 1) {
      _items[item.id]!.quantity -= 1;
    } else {
      _items.remove(item.id);
    }
    notifyListeners();
  }

  /// Remove item completely from cart
  void removeItemCompletely(String id) {
    _items.remove(id);
    notifyListeners();
  }

  /// Clear all items
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
