import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileUploadHelper {
  static final supabase = Supabase.instance.client;

  static Future<String> uploadImage(XFile imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
    
    try {
      final bytes = await imageFile.readAsBytes();
      
      await supabase.storage.from('product-images').uploadBinary(
        fileName, 
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600', 
          upsert: false,
          contentType: _getContentType(imageFile.name),
        ),
      );
      
      return supabase.storage.from('product-images').getPublicUrl(fileName);
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }
  
  static String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  static Future<List<String>> uploadMultipleImages(List<XFile> imageFiles) async {
    List<String> imageUrls = [];
    
    for (final imageFile in imageFiles) {
      try {
        final imageUrl = await uploadImage(imageFile);
        imageUrls.add(imageUrl);
      } catch (e) {
        print('Error uploading image ${imageFile.name}: $e');
        rethrow;
      }
    }
    
    return imageUrls;
  }
} 
