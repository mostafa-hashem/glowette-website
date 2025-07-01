import 'package:supabase_flutter/supabase_flutter.dart';

class SampleProducts {
  static final _supabase = Supabase.instance.client;

  static Future<void> addSampleProducts() async {
    final products = [
      {
        'name': 'Centella Light Cleansing Oil 200ml',
        'price': 320.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
        ],
        'description_general': 'زيت تنظيف لطيف مناسب لجميع أنواع البشرة، يزيل المكياج والشوائب بفعالية دون ترك ملمس دهني',
        'key_benefits': 'يهدئ البشرة الحساسة. يزيل المكياج المقاوم للماء. ينظف المسام بعمق. غني بخلاصة السنتيلا',
        'suitable_for': 'جميع أنواع البشرة، خاصة البشرة الحساسة والدهنية',
        'is_available': true,
        'rating': 4.7,
        'reviews_count': 23,
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'name': 'Axis-Y Panthenol 50ml',
        'price': 280.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=400',
        ],
        'description_general': 'سيروم مرطب ومهدئ للبشرة يحتوي على البانثينول وحمض الهيالورونيك لترطيب عميق ومكثف',
        'key_benefits': 'ترطيب مكثف. يهدئ الالتهابات. يقوي حاجز البشرة. يساعد في التئام الجروح الصغيرة',
        'suitable_for': 'البشرة الجافة والحساسة والمتهيجة',
        'is_available': true,
        'rating': 4.5,
        'reviews_count': 18,
        'created_at': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
      },
      {
        'name': 'Anua Niacinamide 10% 30ml',
        'price': 350.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=400',
          'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        ],
        'description_general': 'سيروم النياسيناميد المركز بتركيز 10% لتحسين ملمس البشرة وتقليل ظهور المسام والتحكم في الدهون',
        'key_benefits': 'يقلل المسام الظاهرة. يتحكم في إفراز الدهون. يوحد لون البشرة. يقلل البقع الداكنة',
        'suitable_for': 'البشرة الدهنية والمختلطة والمعرضة لحب الشباب',
        'is_available': true,
        'rating': 4.8,
        'reviews_count': 45,
        'created_at': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      },
      {
        'name': 'Axis-Y Collagen Eye Serum 10ml',
        'price': 290.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1607748851694-60b6a222c0f2?w=400',
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ],
        'description_general': 'سيروم العين المخصص لتقليل الخطوط الدقيقة والانتفاخ حول العينين بفضل الكولاجين والكافيين',
        'key_benefits': 'يقلل الهالات السوداء. ينعم الخطوط الدقيقة. يقلل انتفاخ العينين. يحفز تجديد الخلايا',
        'suitable_for': 'جميع أنواع البشرة، خاصة من تعاني من علامات التقدم في السن',
        'is_available': true,
        'rating': 4.3,
        'reviews_count': 12,
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'name': 'BHA Treatment Toner 150ml',
        'price': 310.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
          'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=400',
        ],
        'description_general': 'تونر مقشر لطيف يحتوي على أحماض البيتا هيدروكسي لتنظيف المسام وتقشير الطبقة العليا من الجلد',
        'key_benefits': 'ينظف المسام بعمق. يقشر خلايا الجلد الميتة. يقلل الرؤوس السوداء. ينعم ملمس البشرة',
        'suitable_for': 'البشرة الدهنية والمعرضة لحب الشباب',
        'is_available': false,
        'rating': 4.6,
        'reviews_count': 34,
        'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'name': 'Centella Soothing Cream 75ml',
        'price': 265.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=400',
          'https://images.unsplash.com/photo-1607748851694-60b6a222c0f2?w=400',
        ],
        'description_general': 'كريم مهدئ ومرطب مناسب للاستخدام اليومي، يحتوي على خلاصة السنتيلا المهدئة للبشرة الحساسة',
        'key_benefits': 'يهدئ التهابات البشرة. ترطيب يدوم 24 ساعة. يقوي حاجز البشرة الطبيعي. مناسب للاستخدام اليومي',
        'suitable_for': 'البشرة الحساسة والجافة والمتهيجة',
        'is_available': true,
        'rating': 4.4,
        'reviews_count': 28,
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'name': 'Axis-Y Gel Cleanser 180ml',
        'price': 195.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
        ],
        'description_general': 'جل منظف لطيف ينظف البشرة دون جفاف، مناسب للاستخدام اليومي صباحاً ومساءً',
        'key_benefits': 'تنظيف لطيف وفعال. لا يسبب جفاف البشرة. يزيل الشوائب والزيوت الزائدة. رغوة كريمية لطيفة',
        'suitable_for': 'جميع أنواع البشرة، خاصة البشرة العادية والمختلطة',
        'is_available': true,
        'rating': 4.2,
        'reviews_count': 16,
        'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      },
      {
        'name': 'Centella Ampoule Foam 125ml',
        'price': 220.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
        ],
        'description_general': 'فوم منظف غني بخلاصة السنتيلا، ينظف البشرة برفق ويتركها نظيفة ومنتعشة دون شعور بالجفاف',
        'key_benefits': 'تنظيف عميق ولطيف. يهدئ البشرة المتهيجة. رغوة كثيفة ونعومة. مناسب للاستخدام اليومي',
        'suitable_for': 'البشرة الحساسة والعادية',
        'is_available': true,
        'rating': 4.0,
        'reviews_count': 9,
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'name': 'Centella Ampoule Serum 55ml',
        'price': 385.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=400',
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=400',
        ],
        'description_general': 'سيروم مركز بخلاصة السنتيلا بتركيز عالي لعلاج البشرة المتهيجة والحساسة وتهدئة الالتهابات',
        'key_benefits': 'تركيز عالي من السنتيلا. يعالج الالتهابات سريعاً. يهدئ الحساسية. يسرع عملية الشفاء',
        'suitable_for': 'البشرة الحساسة جداً والمعرضة للالتهابات',
        'is_available': true,
        'rating': 4.9,
        'reviews_count': 67,
        'created_at': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      },
      {
        'name': 'Carmex Lip Balm',
        'price': 45.0,
        'image_urls': [
          'https://images.unsplash.com/photo-1607748851694-60b6a222c0f2?w=400',
          'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        ],
        'description_general': 'مرطب شفاه كلاسيكي يوفر ترطيباً مكثفاً وحماية للشفاه الجافة والمتشققة',
        'key_benefits': 'ترطيب مكثف وفوري. يعالج تشقق الشفاه. حماية من العوامل الخارجية. ملمس ناعم ومريح',
        'suitable_for': 'الشفاه الجافة والمتشققة - للجميع',
        'is_available': true,
        'rating': 4.1,
        'reviews_count': 8,
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    try {
      for (final product in products) {
        await _supabase.from('products').insert(product);
        print('Added: ${product['name']}');
      }
      print('✅ All sample products added successfully!');
    } catch (e) {
      print('❌ Error adding products: $e');
    }
  }

  static Future<void> addSampleReviews() async {
    final reviews = [
      // Reviews for Centella Light Cleansing Oil
      {
        'product_id': 1,
        'reviewer_name': 'سارة أحمد',
        'rating': 5,
        'comment': 'منتج رائع! ينظف البشرة بلطف ولا يترك ملمس دهني',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'product_id': 1,
        'reviewer_name': 'مريم خالد',
        'rating': 4,
        'comment': 'يزيل المكياج بفعالية، بس الرائحة مش عاجباني أوي',
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'product_id': 1,
        'reviewer_name': 'نور محمد',
        'rating': 5,
        'comment': 'مناسب جداً للبشرة الحساسة ومايسببش حساسية',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },

      // Reviews for Anua Niacinamide
      {
        'product_id': 3,
        'reviewer_name': 'هند عبدالله',
        'rating': 5,
        'comment': 'شايفة فرق واضح في البشرة بعد أسبوعين استخدام',
        'created_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'product_id': 3,
        'reviewer_name': 'ياسمين علي',
        'rating': 4,
        'comment': 'قلل المسام فعلاً، بس في البداية سبب شوية تهيج',
        'created_at': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
      },

      // Reviews for Centella Ampoule Serum
      {
        'product_id': 9,
        'reviewer_name': 'فاطمة حسن',
        'rating': 5,
        'comment': 'أفضل سيروم استخدمته! هدا التهاب البشرة في يومين',
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'product_id': 9,
        'reviewer_name': 'دعاء صالح',
        'rating': 5,
        'comment': 'مناسب جداً للبشرة الحساسة ونتائجه سريعة',
        'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      },
    ];

    try {
      for (final review in reviews) {
        await _supabase.from('reviews').insert(review);
        print('Added review by: ${review['reviewer_name']}');
      }
      print('✅ All sample reviews added successfully!');
    } catch (e) {
      print('❌ Error adding reviews: $e');
    }
  }
} 