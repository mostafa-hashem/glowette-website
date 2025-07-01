import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class FilterOptions {
  final double minPrice;
  final double maxPrice;
  final double minRating;

  FilterOptions({
    this.minPrice = 0,
    this.maxPrice = 999999,
    this.minRating = 0,
  });

  bool get hasActiveFilters =>
      minPrice > 0 || maxPrice < 999999 || minRating > 0;
}

class FilterWidget extends StatefulWidget {
  final FilterOptions initialFilters;
  final Function(FilterOptions) onFiltersChanged;
  final double maxPriceLimit;

  const FilterWidget({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    this.maxPriceLimit = 1000,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  RangeValues _priceRange = const RangeValues(0, 1000);
  double _selectedRating = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // تأكد من أن القيم في النطاق الصحيح
    double minPrice = widget.initialFilters.minPrice.clamp(0, widget.maxPriceLimit);
    double maxPrice = widget.initialFilters.maxPrice == 999999 
        ? widget.maxPriceLimit 
        : widget.initialFilters.maxPrice.clamp(0, widget.maxPriceLimit);
    
    _priceRange = RangeValues(minPrice, maxPrice);
    _selectedRating = widget.initialFilters.minRating;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _applyFilters() {
    final filters = FilterOptions(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minRating: _selectedRating,
    );
    widget.onFiltersChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      _priceRange = RangeValues(0, widget.maxPriceLimit);
      _selectedRating = 0;
    });
    _applyFilters();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_priceRange.start > 0 || _priceRange.end < widget.maxPriceLimit) {
      count++;
    }
    if (_selectedRating > 0) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: themeProvider.isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : const Color(0xFFE57F84).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFilterHeader(themeProvider),
              SizeTransition(
                sizeFactor: _animation,
                child: _buildFilterContent(themeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterHeader(ThemeProvider themeProvider) {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              color: themeProvider.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'فلاتر البحث',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ),
            if (_activeFilterCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_activeFilterCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: themeProvider.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterContent(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          _buildPriceFilter(themeProvider),
          const SizedBox(height: 24),
          _buildRatingFilter(themeProvider),
          const SizedBox(height: 24),
          _buildActionButtons(themeProvider),
        ],
      ),
    );
  }

  Widget _buildPriceFilter(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نطاق السعر',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'من ${_priceRange.start.toStringAsFixed(0)} إلى ${_priceRange.end.toStringAsFixed(0)} جنيه',
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: themeProvider.primaryColor,
            inactiveTrackColor: themeProvider.primaryColor.withValues(alpha: 0.3),
            thumbColor: themeProvider.primaryColor,
            overlayColor: themeProvider.primaryColor.withValues(alpha: 0.2),
            valueIndicatorColor: themeProvider.primaryColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0,
            max: widget.maxPriceLimit,
            divisions: 20,
            labels: RangeLabels(
              '${_priceRange.start.toStringAsFixed(0)} جنيه',
              '${_priceRange.end.toStringAsFixed(0)} جنيه',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
              _applyFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingFilter(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أقل تقييم',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = _selectedRating >= rating;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = _selectedRating == rating ? 0 : rating.toDouble();
                });
                _applyFilters();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeProvider.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? themeProvider.primaryColor
                        : themeProvider.secondaryTextColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : themeProvider.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rating+',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? themeProvider.primaryColor
                            : themeProvider.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeProvider.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'مسح الفلاتر',
              style: TextStyle(
                color: themeProvider.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _applyFilters();
              _toggleExpanded();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'تطبيق الفلاتر',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
} 
