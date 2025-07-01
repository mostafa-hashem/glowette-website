import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/search_widget.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  bool isSearching = false;
  String searchQuery = '';
  
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
    setState(() => isLoading = true);
    
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);

      allProducts = response.map<Product>((map) => Product.fromMap(map)).toList();
      filteredProducts = allProducts;
      
      _fadeController.forward();
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        filteredProducts = allProducts;
      } else {
        filteredProducts = allProducts.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.descriptionGeneral.toLowerCase().contains(query.toLowerCase()) ||
                 product.keyBenefits.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
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
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: isLoading
                    ? const Center(child: LoadingIndicator(size: 50))
                    : _buildProductGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double sidePadding = 20;
        if (constraints.maxWidth > 800) sidePadding = 40;
        if (constraints.maxWidth > 1200) sidePadding = 60;
        
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    foregroundColor: const Color(0xFFE57F84),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك في',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B7D7D),
                        ),
                      ),
                      Text(
                        'Glowette',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE57F84),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            foregroundColor: const Color(0xFFE57F84),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (cartProvider.itemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE57F84),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cartProvider.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double sidePadding = 20;
        if (constraints.maxWidth > 800) sidePadding = 40;
        if (constraints.maxWidth > 1200) sidePadding = 60;
        
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 10),
            child: SearchWidget(
              hintText: 'ابحث عن المنتجات...',
              onSearchChanged: _onSearchChanged,
              isLoading: false,
              debounceTime: 500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    if (filteredProducts.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                size: 80,
                color: const Color(0xFFE57F84).withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                isSearching ? 'لا توجد نتائج للبحث' : 'لا توجد منتجات',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E4A47),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isSearching 
                    ? 'جرب البحث بكلمات مختلفة'
                    : 'تحقق مرة أخرى لاحقاً',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B7D7D),
                ),
              ),
              if (isSearching) ...[
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            double sidePadding = 20;
            double maxWidth = 1400;
            
            if (constraints.maxWidth > 800) {
              sidePadding = 40;
            }
            if (constraints.maxWidth > 1200) {
              sidePadding = 60;
            }
            
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSearching) ...[
                      Text(
                        'نتائج البحث عن "${searchQuery}"',
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
                      child: LayoutBuilder(
                        builder: (context, gridConstraints) {
                          int crossAxisCount = 2;
                          double childAspectRatio = 0.65;
                          double spacing = 12;
                          
                          final effectiveWidth = gridConstraints.maxWidth;
                          
                          if (effectiveWidth > 1200) {
                            crossAxisCount = 5;
                            childAspectRatio = 0.70;
                            spacing = 16;
                          } else if (effectiveWidth > 900) {
                            crossAxisCount = 4;
                            childAspectRatio = 0.67;
                            spacing = 14;
                          } else if (effectiveWidth > 600) {
                            crossAxisCount = 3;
                            childAspectRatio = 0.66;
                            spacing = 12;
                          } else if (effectiveWidth < 400) {
                            childAspectRatio = 0.63;
                            spacing = 10;
                          }
                          
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: value,
                                      child: ProductCard(
                                        product: product,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
