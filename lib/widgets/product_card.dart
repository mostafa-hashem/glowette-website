import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/product_detail_screen.dart';
import 'loading_indicator.dart';

class AnimatedProductCard extends StatefulWidget {
  final int index;
  final Product product;

  const AnimatedProductCard({
    super.key,
    required this.index,
    required this.product,
  });

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (0.1 * widget.index).clamp(0.0, 1.0),
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_animation),
        child: ProductCard(product: widget.product),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  bool get _isNewProduct {
    final daysSinceCreated = DateTime.now().difference(widget.product.createdAt).inDays;
    return daysSinceCreated <= 7;
  }

  String get _getShortDescription {
    if (widget.product.descriptionGeneral.length <= 90) {
      return widget.product.descriptionGeneral;
    }
    return '${widget.product.descriptionGeneral.substring(0, 87)}...';
  }

  @override
  Widget build(BuildContext context) {
    final firstImage = widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : null;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailScreen(product: widget.product),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: Card(
            elevation: _isHovered ? 16 : 8,
            shadowColor: const Color(0xFFE57F84).withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFFDF8F5).withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildImageSection(firstImage),
                    ),
                    Expanded(
                      flex: 4,
                      child: _buildContentSection(),
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

  Widget _buildImageSection(String? firstImage) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Hero(
            tag: firstImage ?? 'product_${widget.product.id}',
            child: firstImage != null
                ? Image.network(
              firstImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: LoadingIndicator(size: 25));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  ),
                );
              },
            )
                : Container(
              color: Colors.grey[100],
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
              ),
            ),
          ),
        ),
        
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              if (_isNewProduct)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.new_releases, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.product.isAvailable 
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.9)
                      : const Color(0xFFFF5722).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.product.isAvailable 
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.product.availabilityText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.product.name,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              color: Color(0xFF2D2D2D),
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.product.price.toStringAsFixed(2)} جنيه',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFFE57F84),
                  ),
                ),
              ),
              _buildRatingStars(),
            ],
          ),
          
          const SizedBox(height: 4),
          
                      Flexible(
              child: Text(
                _getShortDescription,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  height: 1.1,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          const SizedBox(height: 4),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE57F84).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getMainBenefit(),
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFFE57F84),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    final rating = widget.product.rating;
    final reviewsCount = widget.product.reviewsCount;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return const Icon(
              Icons.star,
              size: 10,
              color: Color(0xFFFFD700),
            );
          } else if (index < rating) {
            return const Icon(
              Icons.star_half,
              size: 10,
              color: Color(0xFFFFD700),
            );
          } else {
            return Icon(
              Icons.star_border,
              size: 10,
              color: Colors.grey[400],
            );
          }
        }),
        if (reviewsCount > 0) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewsCount)',
            style: TextStyle(
              fontSize: 7,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  String _getMainBenefit() {
    if (widget.product.keyBenefits.length <= 30) {
      return widget.product.keyBenefits;
    }
    
    final sentences = widget.product.keyBenefits.split('.');
    if (sentences.isNotEmpty && sentences.first.length <= 30) {
      return sentences.first.trim();
    }
    
    return '${widget.product.keyBenefits.substring(0, 27)}...';
  }
}