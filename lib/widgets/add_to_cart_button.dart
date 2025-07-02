import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class AddToCartButton extends StatefulWidget {
  final Product product;
  final ProductVariation? selectedVariation;
  final bool isCompact;
  final VoidCallback? onAdded;

  const AddToCartButton({
    super.key,
    required this.product,
    this.selectedVariation,
    this.isCompact = false,
    this.onAdded,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (widget.selectedVariation != null) {
      final cartItem = CartItem(
        product: widget.product,
        selectedVariation: widget.selectedVariation,
      );
      
      if (cartProvider.isInCartWithVariation(widget.product.id, widget.selectedVariation)) {
        await cartProvider.removeFromCartWithVariation(widget.product.id, widget.selectedVariation);
        cartProvider.showRemovedFromCartMessage( widget.product.name);
      } else {
        await cartProvider.addCartItem(cartItem);
        cartProvider.showAddedToCartMessage( widget.product.name);
      }
    } else {
      if (cartProvider.isInCart(widget.product.id)) {
        await cartProvider.removeFromCart(widget.product.id);
        cartProvider.showRemovedFromCartMessage( widget.product.name);
      } else {
        await cartProvider.addToCart(widget.product);
        cartProvider.showAddedToCartMessage( widget.product.name);
      }
    }
    
    widget.onAdded?.call();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = widget.selectedVariation != null 
            ? cartProvider.isInCartWithVariation(widget.product.id, widget.selectedVariation)
            : cartProvider.isInCart(widget.product.id);
        final quantity = widget.selectedVariation != null
            ? cartProvider.getQuantityWithVariation(widget.product.id, widget.selectedVariation)
            : cartProvider.getQuantity(widget.product.id);

        if (widget.isCompact) {
          return _buildCompactButton(isInCart, quantity);
        } else {
          return _buildFullButton(isInCart, quantity);
        }
      },
    );
  }

  Widget _buildCompactButton(bool isInCart, int quantity) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Tooltip(
        message: isInCart 
            ? 'إزالة من السلة${quantity > 1 ? ' ($quantity منتج)' : ''}' 
            : 'إضافة للسلة',
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isInCart 
                ? const Color(0xFFE57F84) 
                : Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE57F84),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE57F84).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isLoading ? null : _handleAddToCart,
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isInCart ? Colors.white : const Color(0xFFE57F84),
                          ),
                        ),
                      )
                    : Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                            color: isInCart ? Colors.white : const Color(0xFFE57F84),
                            size: 20,
                          ),
                          if (isInCart && quantity > 1)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullButton(bool isInCart, int quantity) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Tooltip(
        message: isInCart 
            ? 'إزالة من السلة${quantity > 1 ? ' ($quantity منتج)' : ''}' 
            : 'إضافة للسلة',
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleAddToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: isInCart 
                  ? const Color(0xFFE57F84) 
                  : Colors.white,
              foregroundColor: isInCart 
                  ? Colors.white 
                  : const Color(0xFFE57F84),
              elevation: 8,
              shadowColor: const Color(0xFFE57F84).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: const Color(0xFFE57F84),
                  width: 2,
                ),
              ),
            ),
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isInCart ? Colors.white : const Color(0xFFE57F84),
                      ),
                    ),
                  )
                : Icon(
                    isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart
                  ),
            label: Text(
              isInCart 
                  ? 'إزالة من السلة${quantity > 1 ? ' ($quantity)' : ''}' 
                  : 'إضافة للسلة',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 