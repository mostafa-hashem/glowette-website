import 'package:flutter/material.dart';

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error, duration: const Duration(seconds: 5));
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }
}

enum ToastType { success, error, warning, info }

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _slideController.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFFE57F84);
      case ToastType.error:
        return const Color(0xFFFF5252);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case ToastType.success:
        return 'نجح';
      case ToastType.error:
        return 'خطأ';
      case ToastType.warning:
        return 'تحذير';
      case ToastType.info:
        return 'معلومة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 20,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getBackgroundColor().withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: _getBackgroundColor().withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getBackgroundColor().withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(),
                          color: _getBackgroundColor(),
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitle(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getBackgroundColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4E4A47),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 4,
                      width: double.infinity,
                      color: _getBackgroundColor().withValues(alpha: 0.1),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1.0 - _progressController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getBackgroundColor(),
                                    _getBackgroundColor().withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
