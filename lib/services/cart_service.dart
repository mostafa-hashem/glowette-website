import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

// For web localStorage
import 'dart:html' as html show window;

class CartService {
  static const String _cartKey = 'glowette_cart';
  static CartService? _instance;
  
  CartService._();
  
  static CartService get instance {
    _instance ??= CartService._();
    return _instance!;
  }

  List<CartItem> _cartItems = [];
  
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  bool get isEmpty => _cartItems.isEmpty;
  
  bool get isNotEmpty => _cartItems.isNotEmpty;

  Future<void> loadCart() async {
    try {
      String? cartData;
      
      if (kIsWeb) {
        cartData = html.window.localStorage[_cartKey];
      } else {
        final prefs = await SharedPreferences.getInstance();
        cartData = prefs.getString(_cartKey);
      }
      
      if (cartData != null && cartData.isNotEmpty) {
        final List<dynamic> cartList = json.decode(cartData);
        _cartItems = cartList.map((item) => CartItem.fromMap(item)).toList();
      }
    } catch (e) {
      print('Error loading cart: $e');
      _cartItems = [];
    }
  }

  Future<void> _saveCart() async {
    try {
      final cartData = json.encode(_cartItems.map((item) => item.toMap()).toList());
      
      if (kIsWeb) {
        html.window.localStorage[_cartKey] = cartData;
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cartKey, cartData);
      }
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    
    await _saveCart();
  }

  Future<void> removeFromCart(int productId) async {
    _cartItems.removeWhere((item) => item.product.id == productId);
    await _saveCart();
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index].quantity = newQuantity;
      await _saveCart();
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
  }

  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: -1, name: '', price: 0, imageUrls: [], 
        descriptionGeneral: '', keyBenefits: '', suitableFor: ''
      )),
    );
    return item.product.id == -1 ? 0 : item.quantity;
  }

  CartItem? getCartItem(int productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
} 