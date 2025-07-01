import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يمكن فتح الرابط حاليًا',
            textAlign: TextAlign.right,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth > 800) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildDetailsSection(context),
              ),
              Expanded(
                flex: 5,
                child: _buildImageSection(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageSection(context),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildDetailsSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Center(
      child: Hero(
        tag: product.imagePath,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE57F84).withValues(alpha: 80),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              product.imagePath,
              fit: BoxFit.cover,
              width: MediaQuery.sizeOf(context).width * 0.90,
              height: MediaQuery.sizeOf(context).width * 0.90,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${product.price.toStringAsFixed(2)} جنيه مصري',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.description,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            const Text(
              'تواصل معنا عبر:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  context: context,
                  assetPath: 'assets/images/WhatsApp.webp',
                  url: 'https://chat.whatsapp.com/HTUfGdzntWLBT8AFHE120j?mode=ac_c',
                  color: Colors.transparent,
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  context: context,
                  icon: Icons.facebook,
                  url: 'https://www.facebook.com/share/1AgqzJLM8Z/',
                  color: const Color(0xFF1877F2),
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  context: context,
                  assetPath: 'assets/images/Instagram.webp',
                  url: 'https://www.instagram.com/glowette_wm/profilecard/?igsh=MWY1ZWV5Y3g2dG02Zg==',
                  color: Colors.transparent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String url,
    String? assetPath,
    IconData? icon,
    Color color = Colors.black,
  }) {
    return InkWell(
      onTap: () => _launchUrl(context, url),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        padding: assetPath != null ? EdgeInsets.zero : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: assetPath != null ? null : color,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: assetPath != null
            ? ClipOval(child: Image.asset(assetPath, fit: BoxFit.cover))
            : Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
