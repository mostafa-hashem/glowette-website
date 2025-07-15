class Review {
  final int id;
  final int productId;
  final String reviewerName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final bool isApproved;

  Review({
    required this.id,
    required this.productId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isApproved = true,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      productId: map['product_id'],
      reviewerName: map['reviewer_name'] ?? '',
      rating: map['rating'] ?? 5,
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      isApproved: map['is_approved'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'reviewer_name': reviewerName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'is_approved': isApproved,
    };
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    
    if (difference == 0) {
      return 'اليوم';
    } else if (difference == 1) {
      return 'أمس';
    } else if (difference < 7) {
      return 'منذ $difference أيام';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? 'منذ أسبوع' : 'منذ $weeks أسابيع';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? 'منذ شهر' : 'منذ $months أشهر';
    } else {
      final years = (difference / 365).floor();
      return years == 1 ? 'منذ سنة' : 'منذ $years سنوات';
    }
  }

  String get shortName {
    if (reviewerName.length <= 20) return reviewerName;
    return '${reviewerName.substring(0, 17)}...';
  }
} 
