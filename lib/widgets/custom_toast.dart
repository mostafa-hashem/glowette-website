import 'package:flutter/material.dart';

class CustomToast {
  static OverlayEntry? _currentToast;

  static void _showCustomToast(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    String? emoji,
    Duration duration = const Duration(seconds: 3),
  }) {
    _removeCurrentToast();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        emoji: emoji,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
          _currentToast = null;
        },
      ),
    );

    _currentToast = overlayEntry;
    overlay.insert(overlayEntry);
  }

  static void _removeCurrentToast() {
    _currentToast?.remove();
    _currentToast = null;
  }

  static void showSuccess(String message, {String? emoji}) {
    final context = _getContext();
    if (context != null) {
      _showCustomToast(
        context,
        message: message,
        backgroundColor: const Color(0xFF10B981),
        icon: Icons.check_circle_rounded,
        emoji: emoji,
      );
    }
  }

  static void showInfo(String message, {String? emoji}) {
    final context = _getContext();
    if (context != null) {
      _showCustomToast(
        context,
        message: message,
        backgroundColor: const Color(0xFFE57F84),
        icon: Icons.info_rounded,
        emoji: emoji,
      );
    }
  }

  static void showError(String message, {String? emoji}) {
    final context = _getContext();
    if (context != null) {
      _showCustomToast(
        context,
        message: message,
        backgroundColor: const Color(0xFFEF4444),
        icon: Icons.error_rounded,
        emoji: emoji,
        duration: const Duration(seconds: 4),
      );
    }
  }

  static void showWarning(String message, {String? emoji}) {
    final context = _getContext();
    if (context != null) {
      _showCustomToast(
        context,
        message: message,
        backgroundColor: const Color(0xFFF59E0B),
        icon: Icons.warning_rounded,
        emoji: emoji,
      );
    }
  }

  static void showUpdate(String message, {String? emoji}) {
    final context = _getContext();
    if (context != null) {
      _showCustomToast(
        context,
        message: message,
        backgroundColor: const Color(0xFF3B82F6),
        icon: Icons.refresh_rounded,
        emoji: emoji,
      );
    }
  }

  static void showNewItems(int count, {String? emoji}) {
    final context = _getContext();
    if (context != null) {
      _showCustomToast(
        context,
        message: 'تم إضافة $count منتج جديد!',
        backgroundColor: const Color(0xFFE57F84),
        icon: Icons.celebration_rounded,
        emoji: emoji,
        duration: const Duration(seconds: 4),
      );
    }
  }

  static BuildContext? _getContext() {
    return _currentContext;
  }

  static BuildContext? _currentContext;
  
  static void setContext(BuildContext context) {
    _currentContext = context;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final String? emoji;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    this.emoji,
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
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
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.backgroundColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.backgroundColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.emoji != null 
                                    ? '${widget.emoji} ${widget.message}'
                                    : widget.message,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            height: 3,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 1.0 - _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.backgroundColor,
                                      widget.backgroundColor.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
