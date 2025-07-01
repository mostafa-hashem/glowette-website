import 'package:flutter/material.dart';
import 'package:glowette/providers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/platform_image.dart';
import '../widgets/custom_toast.dart';
import '../helper_methouds.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _generalDescController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _suitableForController = TextEditingController();
  
  final List<XFile> _newImageFiles = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;
  bool _isAvailable = true;
  final supabase = Supabase.instance.client;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _generalDescController.text = widget.product.descriptionGeneral;
    _benefitsController.text = widget.product.keyBenefits;
    _suitableForController.text = widget.product.suitableFor;
    _existingImageUrls = List.from(widget.product.imageUrls);
    _isAvailable = widget.product.isAvailable;
    
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
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

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
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      _newImageFiles.addAll(pickedFiles);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_existingImageUrls.isEmpty && _newImageFiles.isEmpty) {
      CustomToast.showWarning(
        'يرجى الاحتفاظ بصورة واحدة على الأقل للمنتج',
        emoji: '⚠️',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> allImageUrls = List.from(_existingImageUrls);

      if (_newImageFiles.isNotEmpty) {
        final newImageUrls = await FileUploadHelper.uploadMultipleImages(_newImageFiles);
        allImageUrls.addAll(newImageUrls);
      }

      await supabase.from('products').update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'image_urls': allImageUrls,
        'description_general': _generalDescController.text,
        'key_benefits': _benefitsController.text,
        'suitable_for': _suitableForController.text,
        'is_available': _isAvailable,
      }).eq('id', widget.product.id);

      CustomToast.showSuccess(
        'تم تحديث المنتج بنجاح! تم حفظ جميع التغييرات.',
        emoji: '✅',
      );

      Navigator.pop(context, true);
    } catch (e) {
      CustomToast.showError(
        'فشل في تحديث المنتج. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
        emoji: '❌',
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
      color: themeProvider.cardColor.withValues(alpha:  0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFE57F84)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: themeProvider.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            labelStyle: TextStyle(color: themeProvider.textColor),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16),
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
                const Icon(Icons.photo_library, color: Color(0xFFE57F84)),
                const SizedBox(width: 10),
                const Text(
                  'صور المنتج',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E4A47),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_existingImageUrls.isNotEmpty) ...[
              const Text(
                                      'الصور الحالية:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E4A47),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFE57F84).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _existingImageUrls.length,
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
                            child: Image.network(
                              _existingImageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _removeExistingImage(index),
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
            ],

            if (_newImageFiles.isNotEmpty) ...[
              const Text(
                                            'الصور الجديدة للإضافة:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E4A47),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _newImageFiles.length,
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
                              imageFile: _newImageFiles[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _removeNewImage(index),
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
            ],

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE57F84).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFFE57F84),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: const Color(0xFFE57F84).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text(
                  'إضافة المزيد من الصور',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
    CustomToast.setContext(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
    backgroundColor: themeProvider.cardColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeProvider.backgroundGradient[0],
              themeProvider.backgroundGradient[1],
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      style: IconButton.styleFrom(
                        backgroundColor: themeProvider.cardColor.withValues(alpha: 0.9),
                        foregroundColor: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'تعديل المنتج',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                          ),
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                              validator: (value) =>
                                  value!.isEmpty ? 'يرجى إدخال اسم المنتج' : null,
                            ),

                            const SizedBox(height: 20),

                            _buildFormField(
                              controller: _priceController,
                              label: 'السعر (جنيه مصري)',
                              hint: 'أدخل السعر بالجنيه المصري',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) return 'يرجى إدخال السعر';
                                if (double.tryParse(value) == null) {
                                  return 'يرجى إدخال سعر صحيح';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            _buildFormField(
                              controller: _generalDescController,
                              label: 'الوصف العام',
                              hint: 'اوصف المنتج بالتفصيل...',
                              icon: Icons.description,
                              maxLines: 4,
                              validator: (value) =>
                                  value!.isEmpty ? 'يرجى إدخال وصف المنتج' : null,
                            ),

                            const SizedBox(height: 20),

                            _buildFormField(
                              controller: _benefitsController,
                              label: 'الفوائد الرئيسية',
                              hint: 'اذكر الفوائد الأساسية...',
                              icon: Icons.star_outline,
                              maxLines: 4,
                              validator: (value) =>
                                  value!.isEmpty ? 'يرجى إدخال فوائد المنتج' : null,
                            ),

                            const SizedBox(height: 20),

                            _buildFormField(
                              controller: _suitableForController,
                              label: 'مناسب لـ',
                              hint: 'لمن هذا المنتج مناسب؟',
                              icon: Icons.people_outline,
                              maxLines: 3,
                              validator: (value) =>
                                  value!.isEmpty ? 'يرجى تحديد من المناسب لهم هذا المنتج' : null,
                            ),

                            const SizedBox(height: 20),

                            Card(
                              elevation: 8,
                              color: themeProvider.cardColor.withValues(alpha: 0.95),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_outlined,
                                      color: const Color(0xFFE57F84),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      'حالة التوفر',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4E4A47),
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
                                      activeColor: const Color(0xFFE57F84),
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
                                        color: const Color(0xFFE57F84).withValues(alpha: 0.1),
                                      ),
                                      child: const Center(
                                        child: LoadingIndicator(size: 35),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _updateProduct,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE57F84),
                                        foregroundColor: themeProvider.textColor,
                                        elevation: 10,
                                        shadowColor: const Color(0xFFE57F84).withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        'تحديث المنتج',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
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
 