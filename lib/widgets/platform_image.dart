import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlatformImage extends StatefulWidget {
  final XFile imageFile;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PlatformImage({
    super.key,
    required this.imageFile,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<PlatformImage> createState() => _PlatformImageState();
}

class _PlatformImageState extends State<PlatformImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      if (kIsWeb) {
        final bytes = await widget.imageFile.readAsBytes();
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (kIsWeb) {
      if (_imageBytes != null) {
        return Image.memory(
          _imageBytes!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      } else {
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    } else {
      return Image.file(
        File(widget.imageFile.path),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
  }
} 