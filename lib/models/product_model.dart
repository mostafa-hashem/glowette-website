import 'dart:convert';

class ProductVariation {
  final String size;
  final double price;
  final bool isAvailable;

  ProductVariation({
    required this.size,
    required this.price,
    this.isAvailable = true,
  });

  factory ProductVariation.fromMap(Map<String, dynamic> map) {
    return ProductVariation(
      size: map['size']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      isAvailable: map['is_available'] == null
          ? true
          : (map['is_available'] is bool
              ? map['is_available'] as bool
              : (map['is_available']?.toString() == 'true')),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'price': price,
      'is_available': isAvailable,
    };
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(2)} جنيه';
  }
}

class Product {
  final int id;
  final String name;
  final List<String> imageUrls;
  final String descriptionGeneral;
  final String keyBenefits;
  final String suitableFor;
  final bool isAvailable;
  final DateTime createdAt;
  final double rating;
  final int reviewsCount;
  final List<ProductVariation> variations;

  Product({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.descriptionGeneral,
    required this.keyBenefits,
    required this.suitableFor,
    this.isAvailable = true,
    DateTime? createdAt,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.variations = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory Product.fromMap(Map<String, dynamic> map) {
    List<ProductVariation> variationsList = [];
    var variationsRaw = map['variations'];
    if (variationsRaw != null) {
      if (variationsRaw is String) {
        try {
          variationsRaw = jsonDecode(variationsRaw);
        } catch (_) {
          variationsRaw = [];
        }
      }
      if (variationsRaw is List) {
        variationsList = variationsRaw
            .map((v) => ProductVariation.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList();
      }
    }

    return Product(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name']?.toString() ?? '',
      imageUrls: (map['image_urls'] is List)
          ? List<String>.from((map['image_urls'] as List).map((e) => e.toString()))
          : [],
      descriptionGeneral: map['description_general']?.toString() ?? '',
      keyBenefits: map['key_benefits']?.toString() ?? '',
      suitableFor: map['suitable_for']?.toString() ?? '',
      isAvailable: map['is_available'] == null
          ? true
          : (map['is_available'] is bool
              ? map['is_available'] as bool
              : (map['is_available']?.toString() == 'true')),
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      rating: double.tryParse(map['rating']?.toString() ?? '0') ?? 0.0,
      reviewsCount: int.tryParse(map['reviews_count']?.toString() ?? '0') ?? 0,
      variations: variationsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_urls': imageUrls,
      'description_general': descriptionGeneral,
      'key_benefits': keyBenefits,
      'suitable_for': suitableFor,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'reviews_count': reviewsCount,
      'variations': variations.map((v) => v.toMap()).toList(),
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

  bool get hasVariations {
    return variations.isNotEmpty;
  }

  double get minPrice {
    if (variations.isEmpty) return 0.0;
    return variations.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    if (variations.isEmpty) return 0.0;
    return variations.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  String get priceRange {
    if (variations.isEmpty) {
      return 'غير محدد';
    }
    if (minPrice == maxPrice) {
      return '${minPrice.toStringAsFixed(2)} جنيه';
    }
    return '${minPrice.toStringAsFixed(2)} - ${maxPrice.toStringAsFixed(2)} جنيه';
  }

  List<ProductVariation> get availableVariations {
    return variations.where((v) => v.isAvailable).toList();
  }
}
