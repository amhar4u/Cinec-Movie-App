import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';

class ProfileService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Update user profile with new information
  static Future<bool> updateProfile({
    required String uid,
    String? name,
    dynamic profileImage, // Can be File or Map with bytes data
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      String? profilePictureUrl;

      // Upload new profile image if provided
      if (profileImage != null) {
        if (profileImage is File) {
          // Handle File for mobile/desktop
          profilePictureUrl = await CloudinaryService.uploadProfilePicture(
            profileImage,
            uid,
          );
        } else if (profileImage is Map && profileImage['bytes'] != null) {
          // Handle bytes data for web
          final bytes = profileImage['bytes'] as Uint8List;
          final fileName = profileImage['name'] as String? ?? 'profile_image.jpg';
          
          // Try signed upload first
          profilePictureUrl = await CloudinaryService.uploadProfilePictureFromBytes(
            bytes,
            uid,
            fileName,
          );
          
          // If signed upload fails, try unsigned upload as fallback
          if (profilePictureUrl == null) {
            print('Signed upload failed, trying unsigned upload...');
            profilePictureUrl = await CloudinaryService.uploadImageUnsigned(
              bytes,
              fileName,
            );
          }
        }

        if (profilePictureUrl == null) {
          throw Exception('Failed to upload profile picture');
        }
      }

      // Update user document in Firestore
      await FirestoreService.updateUserDocument(
        uid: uid,
        name: name,
        profilePictureUrl: profilePictureUrl,
        role: role,
        isActive: isActive,
      );

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Change user password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'weak-password':
          message = 'New password is too weak';
          break;
        case 'requires-recent-login':
          message = 'Please log in again to change your password';
          break;
        default:
          message = 'Failed to change password: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Update email address
  static Future<Map<String, dynamic>> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.updateEmail(newEmail);

      // Send verification email
      await user.sendEmailVerification();

      // Update email in Firestore
      await FirestoreService.updateUserDocument(
        uid: user.uid,
        // Note: We might want to add email field to updateUserDocument
      );

      return {
        'success': true,
        'message': 'Email updated successfully. Please verify your new email.',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Password is incorrect';
          break;
        case 'email-already-in-use':
          message = 'This email is already in use';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'requires-recent-login':
          message = 'Please log in again to change your email';
          break;
        default:
          message = 'Failed to update email: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Delete old profile picture from Cloudinary
  static Future<bool> deleteOldProfilePicture(String? oldImageUrl) async {
    if (oldImageUrl == null || !oldImageUrl.contains('cloudinary.com')) {
      return true; // Not a Cloudinary image, nothing to delete
    }

    try {
      final publicId = CloudinaryService.extractPublicId(oldImageUrl);
      if (publicId != null) {
        return await CloudinaryService.deleteImage(publicId);
      }
      return false;
    } catch (e) {
      print('Error deleting old profile picture: $e');
      return false;
    }
  }

  /// Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    final validations = <String, bool>{
      'hasMinLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumbers': password.contains(RegExp(r'[0-9]')),
      'hasSpecialCharacters': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };

    final isValid = validations.values.every((isValid) => isValid);

    return {
      'isValid': isValid,
      'validations': validations,
      'score': validations.values.where((v) => v).length,
    };
  }

  /// Send password reset email
  static Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Failed to send reset email: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }
}
