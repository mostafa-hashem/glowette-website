import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/search_widget.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_toast.dart';
import '../widgets/filter_widget.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
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
  bool isRefreshing = false;
  bool isSearching = false;
  String searchQuery = '';
  FilterOptions currentFilters = FilterOptions();
  double maxProductPrice = 1000;
  
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
    final bool isRefresh = !isLoading;
    
    if (!isRefresh) {
      setState(() => isLoading = true);
    } else {
      setState(() => isRefreshing = true);
    }
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      final newProducts = response.map<Product>((map) => Product.fromMap(map)).toList();
      final oldCount = allProducts.length;
      
      allProducts = newProducts;
      _calculateMaxPrice();
      _applyFiltersAndSearch();
      
      if (isRefresh) {
        final newCount = allProducts.length;
        if (newCount > oldCount) {
          CustomToast.showNewItems(newCount - oldCount, emoji: '🎉');
        } else if (newCount < oldCount) {
          CustomToast.showUpdate('تم تحديث المنتجات', emoji: '📦');
        } else {
          CustomToast.showSuccess('المنتجات محدثة', emoji: '✅');
        }
      }
      
      _fadeController.forward();
    } catch (e) {
      print('Error loading products: $e');
      if (isRefresh) {
        CustomToast.showError('خطأ في التحديث. تحقق من الاتصال بالإنترنت', emoji: '❌');
      }
    } finally {
      if (mounted) {
        setState(() {
          if (!isRefresh) {
            isLoading = false;
          } else {
            isRefreshing = false;
          }
        });
      }
    }
  }

  void _calculateMaxPrice() {
    if (allProducts.isNotEmpty) {
      maxProductPrice = allProducts
          .map((product) => product.maxPrice)
          .reduce((a, b) => a > b ? a : b);
      
      // تأكد من أن القيمة صحيحة
      if (maxProductPrice <= 0) {
        maxProductPrice = 1000;
      }
      
      if (currentFilters.maxPrice == 999999) {
        currentFilters = FilterOptions(
          minPrice: currentFilters.minPrice,
          maxPrice: maxProductPrice,
          minRating: currentFilters.minRating,
        );
      }
    } else {
      maxProductPrice = 1000; // قيمة افتراضية
    }
  }

  void _applyFiltersAndSearch() {
    List<Product> filtered = allProducts;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               product.descriptionGeneral.toLowerCase().contains(searchQuery.toLowerCase()) ||
               product.keyBenefits.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    filtered = filtered.where((product) {
      final priceCheck = product.minPrice >= currentFilters.minPrice && 
                        product.maxPrice <= currentFilters.maxPrice;
      final ratingCheck = currentFilters.minRating == 0 || 
                         product.rating >= currentFilters.minRating;
      return priceCheck && ratingCheck;
    }).toList();

    // ترتيب المنتجات: المتوفرة الأول
    filtered.sort((a, b) {
      if (a.isAvailable && !b.isAvailable) return -1;
      if (!a.isAvailable && b.isAvailable) return 1;
      return 0;
    });

    filteredProducts = filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty;
      _applyFiltersAndSearch();
    });
  }

  void _onFiltersChanged(FilterOptions filters) {
    setState(() {
      currentFilters = filters;
      _applyFiltersAndSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomToast.setContext(context);
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
    return Scaffold(
      drawer: const AppDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: themeProvider.backgroundGradient,
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchProducts,
                color: themeProvider.primaryColor,
                backgroundColor: themeProvider.cardColor,
                displacement: 40,
                strokeWidth: 3,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildHeader(themeProvider),
                          _buildSearchBar(),
                          _buildFilterBar(),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      child: isLoading
                          ? const Center(child: LoadingIndicator(size: 50))
                          : _buildProductGrid(themeProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
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
                    backgroundColor: themeProvider.surfaceColor,
                    foregroundColor: themeProvider.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك في',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                      Text(
                        'Glowette',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: isRefreshing 
                        ? LinearGradient(
                            colors: [
                              const Color(0xFFE57F84).withValues(alpha: 0.15),
                              const Color(0xFFE57F84).withValues(alpha: 0.25),
                            ],
                          )
                        : null,
                    color: isRefreshing ? null : themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isRefreshing ? [
                      BoxShadow(
                        color: const Color(0xFFE57F84).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: (isRefreshing || isLoading) ? null : _fetchProducts,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isRefreshing 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE57F84)),
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              size: 24,
                              key: ValueKey('refresh_icon'),
                            ),
                    ),
                    tooltip: isRefreshing ? 'جاري التحديث...' : 'تحديث المنتجات',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFFE57F84),
                      disabledForegroundColor: const Color(0xFFE57F84).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
          IconButton(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey(themeProvider.isDarkMode),
                      size: 24,
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: themeProvider.surfaceColor,
                    foregroundColor: themeProvider.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  tooltip: themeProvider.isDarkMode ? 'الوضع المضيء' : 'الوضع المظلم',
          ),
          const SizedBox(width: 8),
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
                            backgroundColor: themeProvider.surfaceColor,
                            foregroundColor: themeProvider.primaryColor,
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
                              decoration: BoxDecoration(
                                color: themeProvider.primaryColor,
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

  Widget _buildFilterBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double sidePadding = 20;
        if (constraints.maxWidth > 800) sidePadding = 40;
        if (constraints.maxWidth > 1200) sidePadding = 60;
        
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 10),
            child: FilterWidget(
              initialFilters: currentFilters,
              onFiltersChanged: _onFiltersChanged,
              maxPriceLimit: maxProductPrice,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(ThemeProvider themeProvider) {
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
                color: themeProvider.primaryColor.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                isSearching ? 'لا توجد نتائج للبحث' : 'لا توجد منتجات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isSearching 
                    ? 'جرب البحث بكلمات مختلفة'
                    : 'تحقق مرة أخرى لاحقاً',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.secondaryTextColor,
                ),
              ),
              if (isSearching) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _onSearchChanged(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    Text(
                      '${filteredProducts.length} منتج',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.secondaryTextColor,
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
    );
  }
}
