import 'product_model.dart';

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
    // لو فيه selectedVariation استخدم سعره، لو لأ استخدم أول سعر من الvariations
    if (selectedVariation != null) {
      return selectedVariation!.price;
    } else if (product.variations.isNotEmpty) {
      return product.variations.first.price;
    } else {
      return 0.0;
    }
  }

  double get totalPrice => itemPrice * quantity;

  String get displaySize {
    return selectedVariation?.size ?? (product.variations.isNotEmpty ? product.variations.first.size : 'الحجم الافتراضي');
  }

  String get formattedPrice {
    return '${itemPrice.toStringAsFixed(2)} جنيه';
  }

  Map<String, dynamic> toMap() {
    return {
      'product': {
        'id': product.id,
        'name': product.name,
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
          .map((v) => ProductVariation.fromMap(v))
          .toList();
    }

    ProductVariation? selectedVariation;
    if (map['selected_variation'] != null) {
      selectedVariation = ProductVariation.fromMap(map['selected_variation']);
    }

    return CartItem(
      product: Product(
        id: productMap['id'],
        name: productMap['name'] ?? '',
        imageUrls: List<String>.from(productMap['image_urls'] ?? []),
        descriptionGeneral: productMap['description_general'] ?? '',
        keyBenefits: productMap['key_benefits'] ?? '',
        suitableFor: productMap['suitable_for'] ?? '',
        variations: variations,
      ),
      selectedVariation: selectedVariation,
      quantity: map['quantity'] ?? 1,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
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
