import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // Correct cloud name from your CLOUDINARY_URL
  static const String _cloudName = 'doisntm9x';
  static const String _apiKey = '536538266755367';
  static const String _apiSecret = 'zGUjKNxwrc4Cq7DftvJNjIi0dhs';
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/doisntm9x/image/upload';

  static final Dio _dio = Dio();

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  static Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      // Generate timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Create parameters for signature
      final params = <String, dynamic>{
        'timestamp': timestamp,
        if (folder != null) 'folder': folder,
      };

      // Generate signature
      final signature = _generateSignature(params, _apiSecret);

      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'api_key': _apiKey,
        'timestamp': timestamp,
        'signature': signature,
        if (folder != null) 'folder': folder,
      });

      // Upload to Cloudinary
      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['secure_url'] as String?;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  /// Upload profile picture specifically
  static Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    return await uploadImage(imageFile, folder: 'profile_pictures');
  }

  /// Upload profile picture from bytes (for web)
  static Future<String?> uploadProfilePictureFromBytes(
    Uint8List imageBytes, 
    String userId, 
    String fileName
  ) async {
    try {
      // Generate timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Create parameters for signature (excluding file)
      final params = <String, dynamic>{
        'timestamp': timestamp,
        'folder': 'profile_pictures',
      };

      // Generate signature
      final signature = _generateSignature(params, _apiSecret);

      print('Upload parameters:');
      print('Cloud name: $_cloudName');
      print('API key: $_apiKey');
      print('Timestamp: $timestamp');
      print('Signature: $signature');
      print('Upload URL: $_uploadUrl');

      // Create form data
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
        'api_key': _apiKey,
        'timestamp': timestamp,
        'signature': signature,
        'folder': 'profile_pictures',
      });

      // Upload to Cloudinary
      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['secure_url'] as String?;
      }
      return null;
    } catch (e) {
      print('Error uploading image bytes to Cloudinary: $e');
      return null;
    }
  }

  /// Delete image from Cloudinary using public ID
  static Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final params = <String, dynamic>{
        'public_id': publicId,
        'timestamp': timestamp,
      };

      final signature = _generateSignature(params, _apiSecret);

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy',
        data: {
          'public_id': publicId,
          'api_key': _apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['result'] == 'ok';
      }
      return false;
    } catch (e) {
      print('Error deleting image from Cloudinary: $e');
      return false;
    }
  }

  /// Generate signature for Cloudinary API
  static String _generateSignature(Map<String, dynamic> params, String apiSecret) {
    // Sort parameters
    final sortedParams = <String>[];
    params.forEach((key, value) {
      sortedParams.add('$key=$value');
    });
    sortedParams.sort();

    // Create signature string
    final signatureString = '${sortedParams.join('&')}$apiSecret';
    
    // Generate SHA1 hash
    final bytes = utf8.encode(signatureString);
    final digest = sha1.convert(bytes);
    
    return digest.toString();
  }

  /// Extract public ID from Cloudinary URL
  static String? extractPublicId(String cloudinaryUrl) {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the segment after 'upload' or 'image/upload'
      int uploadIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'upload') {
          uploadIndex = i;
          break;
        }
      }
      
      if (uploadIndex != -1 && uploadIndex + 1 < pathSegments.length) {
        String publicIdWithExtension = pathSegments.sublist(uploadIndex + 1).join('/');
        // Remove file extension
        int lastDotIndex = publicIdWithExtension.lastIndexOf('.');
        if (lastDotIndex != -1) {
          return publicIdWithExtension.substring(0, lastDotIndex);
        }
        return publicIdWithExtension;
      }
      
      return null;
    } catch (e) {
      print('Error extracting public ID: $e');
      return null;
    }
  }

  /// Upload image using unsigned upload (fallback method)
  static Future<String?> uploadImageUnsigned(Uint8List imageBytes, String fileName) async {
    const String uploadPreset = 'ml_default'; // Default preset, or create your own
    
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
        'upload_preset': uploadPreset,
        'folder': 'profile_pictures',
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
      );

      print('Unsigned upload response: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print('Error with unsigned upload: $e');
      return null;
    }
  }
}
