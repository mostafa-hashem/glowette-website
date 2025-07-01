import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_toast.dart';
import '../widgets/search_widget.dart';
import 'edit_product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen>
    with TickerProviderStateMixin {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fetchProducts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      allProducts = response.map<Product>((map) => Product.fromMap(map)).toList();
      filteredProducts = allProducts;
      
      _fadeController.forward();
    } catch (e) {
      print('Error loading products: $e');
      CustomToast.showError('حدث خطأ أثناء تحميل المنتجات', emoji: '❌');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        filteredProducts = allProducts;
      } else {
        filteredProducts = allProducts.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.descriptionGeneral.toLowerCase().contains(query.toLowerCase()) ||
                 product.keyBenefits.toLowerCase().contains(query.toLowerCase()) ||
                 product.id.toString().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await _showDeleteConfirmation(product);
    if (!confirmed) return;

    try {
      await Supabase.instance.client
          .from('products')
          .delete()
          .eq('id', product.id);

      CustomToast.showSuccess('تم حذف ${product.name} بنجاح', emoji: '🗑️');
      _fetchProducts();
    } catch (e) {
      CustomToast.showError('حدث خطأ أثناء حذف المنتج', emoji: '❌');
    }
  }

  Future<bool> _showDeleteConfirmation(Product product) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف المنتج',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E4A47),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من حذف "${product.name}"؟',
              style: const TextStyle(color: Color(0xFF8B7D7D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Color(0xFF8B7D7D)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    CustomToast.setContext(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.cardColor,
      body: Container(
        decoration:    BoxDecoration(
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
              _buildAppBar(),
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: LoadingIndicator(size: 50))
                    : _buildProductsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
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
              'إدارة المنتجات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E4A47),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE57F84).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${filteredProducts.length} منتج',
              style: const TextStyle(
                color: Color(0xFFE57F84),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SearchWidget(
        hintText: 'ابحث عن المنتجات بالاسم أو الوصف أو الرقم...',
        onSearchChanged: _onSearchChanged,
        isLoading: false,
        debounceTime: 600,
      ),
    );
  }

  Widget _buildProductsList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (filteredProducts.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                size: 80,
                color: const Color(0xFFE57F84).withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                _isSearching ? 'لا توجد نتائج للبحث' : 'لا توجد منتجات',
                style:  TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isSearching 
                    ? 'جرب البحث بكلمات مختلفة أو رقم المنتج'
                    : 'ابدأ بإضافة منتجات جديدة',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B7D7D),
                ),
              ),
              if (_isSearching) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _onSearchChanged(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57F84),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.clear),
                  label: const Text('مسح البحث'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _fetchProducts,
        color: const Color(0xFFE57F84),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSearching) ...[
                Text(
                  'نتائج البحث عن "${_searchQuery}"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E4A47),
                  ),
                ),
                Text(
                  '${filteredProducts.length} منتج',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B7D7D),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildProductCard(product),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 8,
      color: themeProvider.cardColor.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B7D7D).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ID: ${product.id}',
                              style:  TextStyle(
                                fontSize: 12,
                                color: themeProvider.secondaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.isAvailable 
                                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                  : const Color(0xFFFF5722).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.availabilityText,
                              style: TextStyle(
                                fontSize: 12,
                                color: product.isAvailable 
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFF5722),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style:  TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(2)} جنيه',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE57F84),
                            ),
                          ),
                          const Spacer(),
                          if (product.hasRating) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4E4A47),
                                  ),
                                ),
                                Text(
                                  ' (${product.reviewsCount})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8B7D7D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تم الإنشاء: ${product.formattedCreatedAt}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B7D7D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProductScreen(product: product),
                        ),
                      );
                      if (result == true) {
                        _fetchProducts();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57F84),
                      foregroundColor: themeProvider.textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text(
                      'تعديل',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteProduct(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: themeProvider.textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text(
                      'حذف',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 