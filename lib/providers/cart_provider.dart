import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../widgets/custom_toast.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService.instance;
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartService.cartItems;
  int get itemCount => _cartService.itemCount;
  double get totalAmount => _cartService.totalAmount;
  bool get isEmpty => _cartService.isEmpty;
  bool get isNotEmpty => _cartService.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _cartService.loadCart();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    await _cartService.addToCart(product, quantity: quantity);
    notifyListeners();
  }

  Future<void> removeFromCart(int productId) async {
    await _cartService.removeFromCart(productId);
    notifyListeners();
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    await _cartService.updateQuantity(productId, newQuantity);
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
    notifyListeners();
  }

  bool isInCart(int productId) {
    return _cartService.isInCart(productId);
  }

  int getQuantity(int productId) {
    return _cartService.getQuantity(productId);
  }

  CartItem? getCartItem(int productId) {
    return _cartService.getCartItem(productId);
  }

  void showAddedToCartMessage(BuildContext context, String productName) {
    CustomToast.showSuccess(
      context,
      'تم إضافة $productName إلى السلة بنجاح!',
    );
  }

  void showRemovedFromCartMessage(BuildContext context, String productName) {
    CustomToast.showInfo(
      context,
      'تم إزالة $productName من السلة.',
    );
  }

  void showUpdatedQuantityMessage(BuildContext context, String productName, int quantity) {
    CustomToast.showInfo(
      context,
      'تم تحديث كمية $productName إلى $quantity.',
    );
  }
} 