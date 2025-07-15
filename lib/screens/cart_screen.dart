import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glowette/models/product_model.dart';
import 'package:glowette/providers/cart_provider.dart';
import 'package:glowette/providers/theme_provider.dart';
import 'package:glowette/widgets/custom_toast.dart';
import 'package:glowette/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CustomToast.setContext(context);

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.isEmpty) {
                      return _buildEmptyCart();
                    }
                    return _buildCartContent(cartProvider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
            tooltip: 'العودة',
            style: IconButton.styleFrom(
              backgroundColor: themeProvider.cardColor.withValues(alpha: 0.9),
              foregroundColor: themeProvider.textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'سلة التسوق',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cartProvider.itemCount} منتج',
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: themeProvider.cardColor.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Color(0xFFE57F84),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'سلة التسوق فارغة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'أضف بعض المنتجات للبدء!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8D7A78),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor:
                    themeProvider.isDarkMode ? Colors.black : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
              ),
              icon: const Icon(Icons.shopping_bag),
              label: const Text(
                'متابعة التسوق',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                return _buildCartItem(item, cartProvider, index);
              },
            ),
          ),
        ),
        _buildCheckoutSection(cartProvider),
      ],
    );
  }

  Widget _buildCartItem(item, CartProvider cartProvider, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shadowColor: themeProvider.primaryColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.cardColor,
                themeProvider.cardColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'cart_${item.product.id}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: item.product.imageUrls.isNotEmpty as bool
                          ? Image.network(
                              item.product.imageUrls.first as String,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: LoadingIndicator(size: 20),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: themeProvider.cardColor,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Color(0xFF8D7A78),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: themeProvider.cardColor,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF8D7A78),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.selectedVariation != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: themeProvider.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'الحجم: ${item.displaySize}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.primaryColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.itemPrice.toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () {
                              cartProvider.updateQuantityWithVariation(
                                item.product.id as int,
                                item.selectedVariation as ProductVariation,
                                item.quantity - 1 as int,
                              );
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: themeProvider.backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: themeProvider.primaryColor
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textColor,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              cartProvider.updateQuantityWithVariation(
                                item.product.id as int,
                                item.selectedVariation as ProductVariation,
                                item.quantity + 1 as int,
                              );
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              cartProvider.removeFromCartWithVariation(
                                item.product.id as int,
                                item.selectedVariation as ProductVariation,
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red[400],
                            tooltip: 'إزالة المنتج',
                            style: IconButton.styleFrom(
                              backgroundColor: themeProvider.isDarkMode
                                  ? Colors.red[900]
                                  : Colors.red[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: themeProvider.primaryColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(CartProvider cartProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المبلغ الإجمالي',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartProvider.totalAmount.toStringAsFixed(2)} جنيه',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${cartProvider.itemCount} منتج',
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final cartItems = cartProvider.cartItems;
                if (cartItems.isEmpty) {
                  CustomToast.showInfo('السلة فاضية!');
                  return;
                }

                final StringBuffer messageBuffer = StringBuffer();
                messageBuffer.writeln('New order from the app:');
                messageBuffer.writeln('--------------------');
                messageBuffer.writeln('Product Name | Quantity | Size | Price');
                messageBuffer.writeln('--------------------');
                for (final item in cartItems) {
                  messageBuffer.writeln(
                    '${item.product.name} | ${item.quantity} | ${item.displaySize} | ${item.itemPrice.toStringAsFixed(2)} EGP',
                  );
                }
                messageBuffer.writeln('--------------------');
                messageBuffer.write(
                  'Total: ${cartProvider.totalAmount.toStringAsFixed(2)} EGP',
                );
                final String message = messageBuffer.toString();


                if (kIsWeb) {
                  // جرب تفتح لينك واتساب ويب
                  final String encodedMessage = Uri.encodeComponent(message);
                  final String url = 'https://wa.me/201120502733?text=$encodedMessage';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('انسخ الرسالة وابعتها على واتساب'),
                        content: SingleChildScrollView(child: SelectableText(message)),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: message));
                              Navigator.of(context).pop();
                              CustomToast.showSuccess('تم نسخ الرسالة!');
                            },
                            child: const Text('نسخ الرسالة'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('إغلاق'),
                          ),
                        ],
                      ),
                    );
                  }
                } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                  // desktop: dialog with copy
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('انسخ الرسالة وابعتها على واتساب'),
                      content: SingleChildScrollView(child: SelectableText(message)),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: message));
                            Navigator.of(context).pop();
                            CustomToast.showSuccess('تم نسخ الرسالة!');
                          },
                          child: const Text('نسخ الرسالة'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إغلاق'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Uri.encodeComponent(message);
                  const String phone = '201120502733';
                  final uri = Uri(
                    scheme: 'whatsapp',
                    path: 'send',
                    queryParameters: {
                      'phone': phone,
                      'text': message,
                    },
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    CustomToast.showError('مش قادر أفتح الواتساب! تأكد إنه متثبت عندك.');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.cardColor,
                foregroundColor: themeProvider.isDarkMode
                    ? Colors.white
                    : themeProvider.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 24),
              label: const Text(
                'متابعة للدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
