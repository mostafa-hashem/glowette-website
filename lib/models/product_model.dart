class Product {
  final int id;
  final String name;
  final double price;
  final List<String> imageUrls;
  final String descriptionGeneral;
  final String keyBenefits;
  final String suitableFor;
  final bool isAvailable;
  final DateTime createdAt;
  final double rating;
  final int reviewsCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    required this.descriptionGeneral,
    required this.keyBenefits,
    required this.suitableFor,
    this.isAvailable = true,
    DateTime? createdAt,
    this.rating = 0.0,
    this.reviewsCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      descriptionGeneral: map['description_general'] ?? '',
      keyBenefits: map['key_benefits'] ?? '',
      suitableFor: map['suitable_for'] ?? '',
      isAvailable: map['is_available'] ?? true,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      rating: (map['rating'] as num? ?? 0.0).toDouble(),
      reviewsCount: map['reviews_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_urls': imageUrls,
      'description_general': descriptionGeneral,
      'key_benefits': keyBenefits,
      'suitable_for': suitableFor,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'reviews_count': reviewsCount,
    };
  }

  String get formattedCreatedAt {
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

  String get availabilityText {
    return isAvailable ? 'متوفر' : 'غير متوفر';
  }

  String get ratingText {
    if (reviewsCount == 0) return 'لا توجد تقييمات';
    return '${rating.toStringAsFixed(1)} ($reviewsCount تقييم)';
  }

  bool get hasRating {
    return reviewsCount > 0 && rating > 0;
  }
}