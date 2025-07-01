import 'package:flutter/material.dart';
import 'package:glowette/screens/manage_reviews_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_toast.dart';
import '../widgets/platform_image.dart';
import 'login_screen.dart';
import 'manage_products_screen.dart';
import '../helper_methouds.dart';

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
      _imageFiles.addAll(pickedFiles);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate() || _imageFiles.isEmpty) {
      CustomToast.showWarning(
        context,
        'يرجى ملء جميع الحقول واختيار صورة واحدة على الأقل',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<String> imageUrls =
          await FileUploadHelper.uploadMultipleImages(_imageFiles);

      await supabase.from('products').insert({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'image_urls': imageUrls,
        'description_general': _generalDescController.text,
        'key_benefits': _benefitsController.text,
        'suitable_for': _suitableForController.text,
        'is_available': _isAvailable,
        'created_at': DateTime.now().toIso8601String(),
      });

      CustomToast.showSuccess(
        context,
        'تم رفع المنتج بنجاح! المنتج متاح الآن في المتجر.',
      );
      _formKey.currentState!.reset();
      setState(() {
        _imageFiles.clear();
      });
    } catch (e) {
      CustomToast.showError(
        context,
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
    return Card(
      elevation: 8,
      color: Colors.white.withValues(alpha: 0.95),
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
            fillColor: const Color(0xFFF8F8F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            labelStyle: const TextStyle(color: Color(0xFF4E4A47)),
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
    return Card(
      elevation: 8,
      color: Colors.white.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: const Color(0xFFE57F84)),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFE57F84).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: _imageFiles.isEmpty
                  ? Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 60,
                          color: const Color(0xFFE57F84).withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'لم يتم اختيار صور',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8B7D7D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'اضغط على الزر بالأسفل لاختيار الصور',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB8A5A5),
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
                      const Color(0xFFE57F84).withValues(alpha: 0.1),
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
                  'اختيار الصور',
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF8F5),
              Color(0xFFF8E8E9),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: const Color(0xFF4E4A47),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        'رفع منتج جديد',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4E4A47),
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
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
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
                            const Color(0xFFE57F84).withValues(alpha: 0.1),
                        foregroundColor: const Color(0xFFE57F84),
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
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
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
                            const Color(0xFFE57F84).withValues(alpha: 0.1),
                        foregroundColor: const Color(0xFFE57F84),
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
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
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
                              color: Colors.white.withValues(alpha: 0.95),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
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
                                        color: const Color(0xFFE57F84)
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
                                            const Color(0xFFE57F84),
                                        foregroundColor: Colors.white,
                                        elevation: 10,
                                        shadowColor: const Color(0xFFE57F84)
                                            .withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        'رفع المنتج',
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
