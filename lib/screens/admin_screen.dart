import 'package:flutter/material.dart';
import 'package:glowette/helper_methouds.dart';
import 'package:glowette/models/product_model.dart';
import 'package:glowette/providers/theme_provider.dart';
import 'package:glowette/screens/login_screen.dart';
import 'package:glowette/screens/manage_products_screen.dart';
import 'package:glowette/screens/manage_reviews_screen.dart';
import 'package:glowette/widgets/custom_toast.dart';
import 'package:glowette/widgets/loading_indicator.dart';
import 'package:glowette/widgets/platform_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _generalDescController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _suitableForController = TextEditingController();
  final List<XFile> _imageFiles = [];
  final List<ProductVariation> _variations = [];
  final _variationSizeController = TextEditingController();
  final _variationPriceController = TextEditingController();
  bool _isLoading = false;
  bool _isAvailable = true;
  final supabase = Supabase.instance.client;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _generalDescController.dispose();
    _benefitsController.dispose();
    _suitableForController.dispose();
    _variationSizeController.dispose();
    _variationPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      _imageFiles.addAll(pickedFiles);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _addVariation() {
    if (_variationSizeController.text.isEmpty ||
        _variationPriceController.text.isEmpty) {
      CustomToast.showWarning('يرجى إدخال الحجم والسعر');
      return;
    }

    final price = double.tryParse(_variationPriceController.text);
    if (price == null) {
      CustomToast.showWarning('يرجى إدخال سعر صحيح');
      return;
    }

    final variation = ProductVariation(
      size: _variationSizeController.text.trim(),
      price: double.parse(_variationPriceController.text.trim()),
    );

    setState(() {
      _variations.add(variation);
      _variationSizeController.clear();
      _variationPriceController.clear();
    });

    CustomToast.showSuccess('تم إضافة الحجم بنجاح');
  }

  void _removeVariation(int index) {
    setState(() {
      _variations.removeAt(index);
    });
  }

  void _clearAllFields() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _priceController.clear();
    _generalDescController.clear();
    _benefitsController.clear();
    _suitableForController.clear();
    _variationSizeController.clear();
    _variationPriceController.clear();
    setState(() {
      _imageFiles.clear();
      _variations.clear();
      _isAvailable = true;
    });
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate() || _imageFiles.isEmpty) {
      CustomToast.showWarning(
        'يرجى ملء جميع الحقول واختيار صورة واحدة على الأقل',
      );
      return;
    }

    if (_variations.isEmpty) {
      CustomToast.showWarning('لازم تضيف على الأقل حجم وسعر واحد للمنتج');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('variations to upload:  [32m [1m [4m${_variations.map((v) => v.toMap()).toList()} [0m');
      final List<String> imageUrls =
          await FileUploadHelper.uploadMultipleImages(_imageFiles);

      await supabase.from('products').insert({
        'name': _nameController.text,
        'image_urls': imageUrls,
        'description_general': _generalDescController.text,
        'key_benefits': _benefitsController.text,
        'suitable_for': _suitableForController.text,
        'is_available': _isAvailable,
        'created_at': DateTime.now().toIso8601String(),
        'variations': _variations.map((v) => v.toMap()).toList(),
      });

      CustomToast.showSuccess(
        'تم رفع المنتج بنجاح! المنتج متاح الآن في المتجر.',
      );

      _clearAllFields();
    } catch (e) {
      CustomToast.showError(
        'فشل في رفع المنتج. يرجى التحقق من الاتصال بالإنترنت والمحاولة مرة أخرى.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 8,
      color: themeProvider.cardColor.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: themeProvider.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: themeProvider.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            labelStyle: TextStyle(color: themeProvider.textColor),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 16, color: themeProvider.textColor),
        ),
      ),
    );
  }

  Widget _buildVariationsSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 8,
      color: themeProvider.cardColor.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_size, color: themeProvider.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'أحجام وأسعار المنتج',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_variations.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _variations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final variation = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              themeProvider.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  variation.size,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: themeProvider.textColor,
                                  ),
                                ),
                                Text(
                                  variation.formattedPrice,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeVariation(index),
                            icon: const Icon(Icons.delete_outline),
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _variationSizeController,
                    decoration: InputDecoration(
                      labelText: 'الحجم',
                      hintText: 'مثال: 125ml',
                      prefixIcon: Icon(
                        Icons.straighten,
                        color: themeProvider.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: themeProvider.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _variationPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر',
                      hintText: 'مثال: 200',
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: themeProvider.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: themeProvider.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addVariation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'إضافة أحجام مختلفة مع أسعارها (اختياري)',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 8,
      color: themeProvider.cardColor.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: themeProvider.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'صور المنتج',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: themeProvider.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: _imageFiles.isEmpty
                  ? Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 60,
                          color:
                              themeProvider.primaryColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'لم يتم اختيار صور',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'اضغط على الزر بالأسفل لاختيار الصور',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.secondaryTextColor,
                          ),
                        ),
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _imageFiles.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: PlatformImage(
                                  imageFile: _imageFiles[index],
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.primaryColor.withValues(alpha: 0.1),
                  foregroundColor: themeProvider.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: themeProvider.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(
                  'اختيار الصور',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    CustomToast.setContext(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeProvider.cardColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.primaryColor,
                            themeProvider.primaryColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.primaryColor
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'العودة للصفحة الرئيسية',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'رفع منتج جديد',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ManageProductsScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      icon: const Icon(Icons.inventory_2),
                      tooltip: 'إدارة المنتجات',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            themeProvider.primaryColor.withValues(alpha: 0.1),
                        foregroundColor: themeProvider.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ManageReviewsScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review),
                      tooltip: 'إدارة المراجعات',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            themeProvider.primaryColor.withValues(alpha: 0.1),
                        foregroundColor: themeProvider.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'تسجيل خروج',
                      onPressed: () async {
                        await supabase.auth.signOut();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginScreen(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildFormField(
                              controller: _nameController,
                              label: 'اسم المنتج',
                              hint: 'أدخل اسم المنتج',
                              icon: Icons.shopping_bag_outlined,
                              validator: (value) => value!.isEmpty
                                  ? 'يرجى إدخال اسم المنتج'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildVariationsSection(),
                            const SizedBox(height: 20),
                            _buildFormField(
                              controller: _generalDescController,
                              label: 'الوصف العام',
                              hint: 'اوصف المنتج بالتفصيل...',
                              icon: Icons.description,
                              maxLines: 4,
                              validator: (value) => value!.isEmpty
                                  ? 'يرجى إدخال وصف المنتج'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              controller: _benefitsController,
                              label: 'الفوائد الرئيسية',
                              hint: 'اذكر الفوائد الأساسية...',
                              icon: Icons.star_outline,
                              maxLines: 4,
                              validator: (value) => value!.isEmpty
                                  ? 'يرجى إدخال فوائد المنتج'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              controller: _suitableForController,
                              label: 'مناسب لـ',
                              hint: 'لمن هذا المنتج مناسب؟',
                              icon: Icons.people_outline,
                              maxLines: 3,
                              validator: (value) => value!.isEmpty
                                  ? 'يرجى تحديد من المناسب لهم هذا المنتج'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            Card(
                              elevation: 8,
                              color: themeProvider.cardColor
                                  .withValues(alpha: 0.95),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_outlined,
                                      color: themeProvider.primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'حالة التوفر',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.textColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    Switch.adaptive(
                                      value: _isAvailable,
                                      onChanged: (value) {
                                        setState(() {
                                          _isAvailable = value;
                                        });
                                      },
                                      activeColor: themeProvider.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isAvailable ? 'متوفر' : 'غير متوفر',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _isAvailable
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFFF5722),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildImageSection(),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: _isLoading
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: themeProvider.primaryColor
                                            .withValues(alpha: 0.1),
                                      ),
                                      child: const Center(
                                        child: LoadingIndicator(size: 35),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _uploadProduct,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            themeProvider.primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 10,
                                        shadowColor: themeProvider.primaryColor
                                            .withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Text(
                                        'رفع المنتج',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: themeProvider.textColor,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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
}
