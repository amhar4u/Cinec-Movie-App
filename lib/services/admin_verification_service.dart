import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AdminVerificationService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if current user is an admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final userDoc = await FirestoreService.getUserDocument(currentUser.uid);
      return userDoc?.role == UserRole.admin;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Get current user model
  static Future<UserModel?> getCurrentUserModel() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      return await FirestoreService.getUserDocument(currentUser.uid);
    } catch (e) {
      print('Error getting current user model: $e');
      return null;
    }
  }

  // Verify admin access and throw exception if not admin
  static Future<void> verifyAdminAccess() async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) {
      throw Exception('Access denied. Admin privileges required.');
    }
  }
}
