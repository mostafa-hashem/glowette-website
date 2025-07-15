import 'package:glowette/models/product_model.dart';

class CartItem {
  final Product product;
  final ProductVariation? selectedVariation;
  int quantity;
  final DateTime addedAt;

  CartItem({
    required this.product,
    this.selectedVariation,
    this.quantity = 1,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get itemPrice {
    return selectedVariation?.price ?? product.price;
  }

  double get totalPrice => itemPrice * quantity;

  String get displaySize {
    return selectedVariation?.size ?? 'الحجم الافتراضي';
  }

  String get formattedPrice {
    return '${itemPrice.toStringAsFixed(2)} جنيه';
  }

  Map<String, dynamic> toMap() {
    return {
      'product': {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'image_urls': product.imageUrls,
        'description_general': product.descriptionGeneral,
        'key_benefits': product.keyBenefits,
        'suitable_for': product.suitableFor,
        'variations': product.variations.map((v) => v.toMap()).toList(),
      },
      'selected_variation': selectedVariation?.toMap(),
      'quantity': quantity,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    final productMap = map['product'];
    List<ProductVariation> variations = [];
    if (productMap['variations'] != null) {
      variations = (productMap['variations'] as List)
          .map((v) => ProductVariation.fromMap(v as Map<String, dynamic>))
          .toList();
    }

    ProductVariation? selectedVariation;
    if (map['selected_variation'] != null) {
      selectedVariation = ProductVariation.fromMap(map['selected_variation'] as Map<String, dynamic>);
    }

    return CartItem(
      product: Product(
        id: productMap['id'] as int? ?? 0,
        name: productMap['name'] as String? ?? '',
        price: (productMap['price'] as num? ?? 0).toDouble(),
        imageUrls: List<String>.from(productMap['image_urls'] as Iterable<dynamic> ?? []),
        descriptionGeneral: productMap['description_general'] as String? ?? '',
        keyBenefits: productMap['key_benefits'] as String? ?? '',
        suitableFor: productMap['suitable_for'] as String? ?? '',
        variations: variations as List<ProductVariation>? ?? [],
      ),
      selectedVariation: selectedVariation,
      quantity: map['quantity'] as int? ?? 1,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int? ?? 0),
    );
  }

  CartItem copyWith({
    Product? product,
    ProductVariation? selectedVariation,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      product: product ?? this.product,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  String get uniqueId {
    return selectedVariation != null
        ? '${product.id}_${selectedVariation!.size}'
        : product.id.toString();
  }
} 
