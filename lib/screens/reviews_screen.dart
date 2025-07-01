import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ReviewsScreen extends StatefulWidget {
  final Product product;

  const ReviewsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with TickerProviderStateMixin {
  List<Review> reviews = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  int _selectedRating = 5;

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
    _loadReviews();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    reviews = await ReviewService.getProductReviews(widget.product.id);
    setState(() => _isLoading = false);
    _fadeController.forward();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ReviewService.addReview(
      productId: widget.product.id,
      reviewerName: _nameController.text,
      rating: _selectedRating,
      comment: _commentController.text,
    );

    if (success) {
      CustomToast.showSuccess(
        'تم إضافة تقييمك بنجاح! شكراً لك على رأيك.',
      );
      _nameController.clear();
      _commentController.clear();
      _selectedRating = 5;
      _loadReviews();
    } else {
      CustomToast.showError(
        'حدث خطأ أثناء إضافة التقييم. يرجى المحاولة مرة أخرى.',
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    CustomToast.setContext(context);
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: LoadingIndicator(size: 50))
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildProductInfo(),
                              const SizedBox(height: 24),
                              _buildRatingSummary(),
                              const SizedBox(height: 24),
                              _buildAddReviewSection(),
                              const SizedBox(height: 32),
                              _buildReviewsList(),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
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
              'التقييمات والمراجعات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 8,
      shadowColor: themeProvider.primaryColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: themeProvider.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.product.imageUrls.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: themeProvider.cardColor,
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: themeProvider.cardColor,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.price.toStringAsFixed(2)} جنيه',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (reviews.isEmpty) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child:  Column(
            children: [
              Icon(
                Icons.star_border,
                size: 60,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد تقييمات بعد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'كن أول من يقيم هذا المنتج!',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final distribution = ReviewService.calculateRatingDistribution(reviews);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        widget.product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE57F84),
                        ),
                      ),
                      _buildStarsRow(widget.product.rating, 20),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.product.reviewsCount} تقييم',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B7D7D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: List.generate(5, (index) {
                      final starCount = 5 - index;
                      final count = distribution[starCount] ?? 0;
                      final percentage = reviews.isNotEmpty 
                          ? count / reviews.length 
                          : 0.0;
                      
                      return _buildRatingBar(starCount, count, percentage);
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsRow(double rating, double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(
            Icons.star,
            size: size,
            color: const Color(0xFFFFD700),
          );
        } else if (index < rating) {
          return Icon(
            Icons.star_half,
            size: size,
            color: const Color(0xFFFFD700),
          );
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: Colors.grey[400],
          );
        }
      }),
    );
  }

  Widget _buildRatingBar(int starCount, int count, double percentage) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$starCount',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Color(0xFFFFD700)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              style: TextStyle(fontSize: 12, color: themeProvider.textColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أضف تقييمك',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'التقييم:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = starIndex;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex <= _selectedRating 
                            ? Icons.star 
                            : Icons.star_border,
                        size: 32,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسمك',
                  hintText: 'أدخل اسمك',
                  prefixIcon: Icon(Icons.person_outline, color: themeProvider.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: themeProvider.primaryColor),
                  ),
                  filled: true,
                  fillColor: themeProvider.surfaceColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسمك';
                  }
                  if (value.trim().length < 2) {
                    return 'الاسم يجب أن يكون حرفين على الأقل';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'تعليقك',
                  hintText: 'شارك رأيك حول المنتج...',
                  prefixIcon: Icon(Icons.comment_outlined, color: themeProvider.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: themeProvider.primaryColor),
                  ),
                  filled: true,
                  fillColor: themeProvider.surfaceColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى كتابة تعليق';
                  }
                  if (value.trim().length < 5) {
                    return 'التعليق يجب أن يكون 5 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isSubmitting
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: themeProvider.primaryColor.withOpacity(0.1),
                        ),
                        child: const Center(
                          child: LoadingIndicator(size: 30),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        icon: const Icon(Icons.send),
                        label: Text(
                          'إرسال التقييم',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المراجعات (${reviews.length})',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: themeProvider.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    review.reviewerName.isNotEmpty 
                        ? review.reviewerName[0].toUpperCase()
                        : '؟',
                    style: TextStyle(
                      color: themeProvider.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.shortName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      Row(
                        children: [
                          _buildStarsRow(review.rating.toDouble(), 14),
                          const SizedBox(width: 8),
                          Text(
                            review.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.secondaryTextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 