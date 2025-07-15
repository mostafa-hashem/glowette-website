import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_toast.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/image_viewer.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'reviews_screen.dart';
import '../providers/theme_provider.dart';

class _ProductImageGallery extends StatefulWidget {
  const _ProductImageGallery({required this.product});
  final Product product;

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery>
    with TickerProviderStateMixin {
  late String _selectedImageUrl;
  late AnimationController _imageController;
  late Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();
    _selectedImageUrl = widget.product.imageUrls.isNotEmpty
        ? widget.product.imageUrls.first
        : '';

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _imageAnimation = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeInOut,
    );
    _imageController.forward();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (_selectedImageUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 100,
          color: Colors.grey,
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: FadeTransition(
              opacity: _imageAnimation,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      barrierColor: Colors.black,
                      pageBuilder: (BuildContext context, _, __) {
                        return ImageViewer(
                          imageUrl: _selectedImageUrl,
                          heroTag: _selectedImageUrl,
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Hero(
                  tag: _selectedImageUrl,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.network(
                            _selectedImageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: LoadingIndicator(size: 30),);
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.zoom_in,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'اضغط للتكبير',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
          ),
        ),
        const SizedBox(height: 16),
        if (widget.product.imageUrls.length > 1)
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: themeProvider.cardColor
                  .withValues(alpha: themeProvider.isDarkMode ? 0.7 : 0.8),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.product.imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = widget.product.imageUrls[index];
                final isSelected = imageUrl == _selectedImageUrl;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageUrl = imageUrl;
                    });
                    _imageController.reset();
                    _imageController.forward();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? themeProvider.primaryColor
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: themeProvider.primaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: LoadingIndicator(size: 15),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  ProductVariation? _selectedVariation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      CustomToast.showError(
        'لا يمكن فتح الرابط الآن. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (screenWidth > 800) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.backgroundGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              SafeArea(
                child: _buildDesktopAppBar(context),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: _buildDetailsSection(context),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: _buildImageSection(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 450,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: _buildBackButton(context),
              actions: [
                _buildCartButton(context),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageSection(context),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildDetailsSection(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopAppBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.product.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildCartButton(context),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
        tooltip: 'العودة للمنتجات',
        color: themeProvider.primaryColor,
      ),
    );
  }

  Widget _buildCartButton(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final itemCount = cartProvider.itemCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                tooltip: 'عرض السلة',
                color: themeProvider.primaryColor,
              ),
            ),
            if (itemCount > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE57F84),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    itemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _ProductImageGallery(product: widget.product),
    );
  }

  Widget _buildVariationsSection(ThemeProvider themeProvider) {
    if (!widget.product.hasVariations) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر الحجم:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E4A47),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: widget.product.availableVariations.map((variation) {
            final isSelected = _selectedVariation == variation;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVariation = variation;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE57F84) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE57F84)
                        : const Color(0xFFE57F84).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFE57F84).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      variation.size,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color:
                            isSelected ? Colors.white : const Color(0xFF4E4A47),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      variation.formattedPrice,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isSelected ? Colors.white : const Color(0xFFE57F84),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.product.name,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    // _selectedVariation != null
                    _selectedVariation?.formattedPrice ?? "اختر الحجم",
                    // : widget.product.priceRange,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6,),
                      decoration: BoxDecoration(
                        color: widget.product.isAvailable
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                            : const Color(0xFFFF5722).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: widget.product.isAvailable
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF5722),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.product.isAvailable
                                ? Icons.check_circle_outline
                                : Icons.remove_circle_outline,
                            size: 16,
                            color: widget.product.isAvailable
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF5722),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.availabilityText,
                            style: TextStyle(
                              color: widget.product.isAvailable
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF5722),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        final isInCart = _selectedVariation != null
                            ? cartProvider.isInCartWithVariation(
                                widget.product.id, _selectedVariation,)
                            : cartProvider.isInCart(widget.product.id);
                        final quantity = _selectedVariation != null
                            ? cartProvider.getQuantityWithVariation(
                                widget.product.id, _selectedVariation,)
                            : cartProvider.getQuantity(widget.product.id);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6,),
                          decoration: BoxDecoration(
                            color: isInCart
                                ? themeProvider.primaryColor
                                    .withValues(alpha: 0.1)
                                : themeProvider.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isInCart
                                  ? themeProvider.primaryColor
                                  : (themeProvider.isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            isInCart ? 'في السلة ($quantity)' : 'ليس في السلة',
                            style: TextStyle(
                              color: isInCart
                                  ? themeProvider.primaryColor
                                  : themeProvider.secondaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildVariationsSection(themeProvider),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: themeProvider.secondaryTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'أُضيف ${widget.product.formattedCreatedAt}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.product.descriptionGeneral,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.5,
                    color: themeProvider.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: '⭐ أهم الفوائد',
              content: widget.product.keyBenefits,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              title: '👌 المناسب لمين؟',
              content: widget.product.suitableFor,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 32),
            AddToCartButton(
              product: widget.product,
              selectedVariation: _selectedVariation,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReviewsScreen(product: widget.product),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.cardColor,
                  foregroundColor: themeProvider.primaryColor,
                  side: BorderSide(color: themeProvider.primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.star_outline),
                label: Text(
                  widget.product.hasRating
                      ? 'عرض التقييمات (${widget.product.reviewsCount})'
                      : 'أضف أول تقييم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSocialSection(context, themeProvider),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      {required String title,
      required String content,
      required ThemeProvider themeProvider,}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.grey[900]
            : const Color(0xFFFDF8F5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: themeProvider.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: themeProvider.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(
      BuildContext context, ThemeProvider themeProvider,) {
    return Column(
      children: [
        const Text(
          'تواصل معنا',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E4A47),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              context: context,
              assetPath: 'assets/images/WhatsApp.webp',
              url: 'https://chat.whatsapp.com/HTUfGdzntWLBT8AFHE120j?mode=ac_t',
              color: Colors.transparent,
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              context: context,
              assetPath: 'assets/images/facebook.webp',
              url: 'https://www.facebook.com/profile.php?id=61577646224307',
              color: const Color(0xFF1877F2),
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              context: context,
              assetPath: 'assets/images/Instagram.webp',
              url: 'https://www.instagram.com/glowette_wm/profilecard/?igsh=MWY1ZWV5Y3g2dG02Zg==',
              color: Colors.transparent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String url,
    String? assetPath,
    IconData? icon,
    Color color = Colors.black,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchUrl(context, url),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            padding:
                assetPath != null ? EdgeInsets.zero : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: assetPath != null ? null : color,
            ),
            child: assetPath != null
                ? ClipOval(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
