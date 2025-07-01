import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final DateTime addedAt;

  CartItem({
    required this.product,
    this.quantity = 1,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get totalPrice => product.price * quantity;

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
      },
      'quantity': quantity,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        id: map['product']['id'],
        name: map['product']['name'] ?? '',
        price: (map['product']['price'] as num? ?? 0).toDouble(),
        imageUrls: List<String>.from(map['product']['image_urls'] ?? []),
        descriptionGeneral: map['product']['description_general'] ?? '',
        keyBenefits: map['product']['key_benefits'] ?? '',
        suitableFor: map['product']['suitable_for'] ?? '',
      ),
      quantity: map['quantity'] ?? 1,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
    );
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
} 