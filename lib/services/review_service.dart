import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewService {
  static final _supabase = Supabase.instance.client;

  // جلب مراجعات منتج معين
  static Future<List<Review>> getProductReviews(int productId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .eq('is_approved', true)
          .order('created_at', ascending: false);

      return response.map<Review>((map) => Review.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // إضافة مراجعة جديدة
  static Future<bool> addReview({
    required int productId,
    required String reviewerName,
    required int rating,
    required String comment,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'product_id': productId,
        'reviewer_name': reviewerName.trim(),
        'rating': rating,
        'comment': comment.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'is_approved': true,
      });

      // تحديث تقييم المنتج ومتوسط النجوم
      await _updateProductRating(productId);
      
      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  // حذف مراجعة (للأدمن فقط)
  static Future<bool> deleteReview(int reviewId, int productId) async {
    try {
      await _supabase.from('reviews').delete().eq('id', reviewId);
      
      // تحديث تقييم المنتج بعد الحذف
      await _updateProductRating(productId);
      
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // جلب جميع المراجعات (للأدمن)
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .order('created_at', ascending: false);

      return response.map<Review>((map) => Review.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching all reviews: $e');
      return [];
    }
  }

  // تحديث تقييم المنتج
  static Future<void> _updateProductRating(int productId) async {
    try {
      // حساب متوسط التقييم
      final reviews = await getProductReviews(productId);
      
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(0, (sum, review) => sum + review.rating);
        final averageRating = totalRating / reviews.length;
        final reviewsCount = reviews.length;

        // تحديث المنتج
        await _supabase
            .from('products')
            .update({
              'rating': double.parse(averageRating.toStringAsFixed(1)),
              'reviews_count': reviewsCount,
            })
            .eq('id', productId);
      } else {
        // لا توجد مراجعات، تصفير التقييم
        await _supabase
            .from('products')
            .update({
              'rating': 0.0,
              'reviews_count': 0,
            })
            .eq('id', productId);
      }
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }

  // حساب إحصائيات التقييم
  static Map<int, int> calculateRatingDistribution(List<Review> reviews) {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = 0;
    }
    
    for (final review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    
    return distribution;
  }
} 