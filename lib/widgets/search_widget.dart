import 'package:flutter/material.dart';
import 'dart:async';

class SearchWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final bool isLoading;
  final int debounceTime;

  const SearchWidget({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    this.isLoading = false,
    this.debounceTime = 800,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  bool _hasText = false;
  
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _hasText = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () {
      widget.onSearchChanged(query.trim());
    });
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFFDF8F5).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE57F84).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: _hasText 
                ? const Color(0xFFE57F84).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4E4A47),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            prefixIcon: widget.isLoading
                ? Container(
                    padding: const EdgeInsets.all(12),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE57F84)),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.search,
                    color: Color(0xFFE57F84),
                    size: 24,
                  ),
            suffixIcon: _hasText
                ? ScaleTransition(
                    scale: _scaleAnimation,
                    child: IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF8B7D7D),
                        size: 20,
                      ),
                      tooltip: 'مسح البحث',
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                color: Color(0xFFE57F84),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
} 