import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 40.0,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              _buildDot(0.0, color.withValues(alpha: 0.3)),
              _buildDot(0.33, color.withValues(alpha: 0.6)),
              _buildDot(0.66, color),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDot(double delay, Color color) {
    return Positioned.fill(
      child: Transform.rotate(
        angle: (_animation.value + delay) * 2 * 3.14159,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: widget.size * 0.25,
            height: widget.size * 0.25,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 