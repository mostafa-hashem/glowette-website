import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../widgets/loading_indicator.dart';

class ManageReviewsScreen extends StatefulWidget {
  const ManageReviewsScreen({super.key});

  @override
  State<ManageReviewsScreen> createState() => _ManageReviewsScreenState();
}

class _ManageReviewsScreenState extends State<ManageReviewsScreen> {
  List<Review> allReviews = [];
  List<Review> filteredReviews = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoading = true);

    try {
      allReviews = await ReviewService.getAllReviews();
      _applyFilters();
    } catch (e) {
      Fluttertoast.showToast(msg: 'خطأ في تحميل المراجعات');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    filteredReviews = allReviews.where((review) {
      final matchesSearch = searchQuery.isEmpty ||
          review.reviewerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          review.comment.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter = selectedFilter == 'الكل' ||
          (selectedFilter == 'معتمدة' && review.isApproved) ||
          (selectedFilter == 'غير معتمدة' && !review.isApproved) ||
          (selectedFilter == '5 نجوم' && review.rating == 5) ||
          (selectedFilter == '4 نجوم' && review.rating == 4) ||
          (selectedFilter == '3 نجوم' && review.rating == 3) ||
          (selectedFilter == '2 نجوم' && review.rating == 2) ||
          (selectedFilter == '1 نجمة' && review.rating == 1);

      return matchesSearch && matchesFilter;
    }).toList();

    filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {});
  }

  Future<void> _deleteReview(Review review) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المراجعة'),
        content: Text('هل أنت متأكد من حذف مراجعة "${review.shortName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        setState(() => isLoading = true);
        final success = await ReviewService.deleteReview(review.id, review.productId);

        if (success) {
          Fluttertoast.showToast(msg: 'تم حذف المراجعة بنجاح');
          await _loadReviews();
        } else {
          Fluttertoast.showToast(msg: 'فشل في حذف المراجعة');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'خطأ في حذف المراجعة');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المراجعات'),
        backgroundColor: const Color(0xFFE57F84),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadReviews,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF8F5),
              Color(0xFFF8E8E9),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildStatsCard(),
            Expanded(
              child: isLoading
                  ? const Center(child: LoadingIndicator(size: 50))
                  : _buildReviewsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              searchQuery = value;
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'ابحث في المراجعات...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFE57F84)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'الكل',
                'معتمدة',
                'غير معتمدة',
                '5 نجوم',
                '4 نجوم',
                '3 نجوم',
                '2 نجوم',
                '1 نجمة',
              ].map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      selectedFilter = filter;
                      _applyFilters();
                    },
                    selectedColor: const Color(0xFFE57F84).withValues(alpha: 0.3),
                    checkmarkColor: const Color(0xFFE57F84),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalReviews = allReviews.length;
    final approvedReviews = allReviews.where((r) => r.isApproved).length;
    final averageRating = totalReviews > 0
        ? allReviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي المراجعات', '$totalReviews', Icons.reviews),
          _buildStatItem('المعتمدة', '$approvedReviews', Icons.check_circle),
          _buildStatItem('متوسط التقييم', averageRating.toStringAsFixed(1), Icons.star),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE57F84), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8B7D7D),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    if (filteredReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty || selectedFilter != 'الكل'
                  ? Icons.search_off
                  : Icons.rate_review_outlined,
              size: 80,
              color: const Color(0xFFE57F84).withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              searchQuery.isNotEmpty || selectedFilter != 'الكل'
                  ? 'لا توجد مراجعات تطابق البحث'
                  : 'لا توجد مراجعات',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E4A47),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      color: const Color(0xFFE57F84),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredReviews.length,
        itemBuilder: (context, index) {
          final review = filteredReviews[index];
          return _buildReviewCard(review);
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        'معرف المنتج: ${review.productId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B7D7D),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFD700),
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteReview(review);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4E4A47),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B7D7D),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: review.isApproved
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : const Color(0xFFFF5722).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    review.isApproved ? 'معتمدة' : 'غير معتمدة',
                    style: TextStyle(
                      fontSize: 12,
                      color: review.isApproved
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF5722),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
