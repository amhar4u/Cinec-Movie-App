import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // Get all users with pagination and filtering
  static Future<List<UserModel>> getAllUsers({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? searchQuery,
    UserRole? roleFilter,
    bool? activeFilter,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection);

      // Apply filters
      if (roleFilter != null) {
        query = query.where('role', isEqualTo: roleFilter.toString().split('.').last);
      }

      if (activeFilter != null) {
        query = query.where('isActive', isEqualTo: activeFilter);
      }

      // Apply ordering
      query = query.orderBy('createdAt', descending: true);

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      List<UserModel> users = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // Apply search filter (client-side for simplicity)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        users = users.where((user) =>
            user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      }

      return users;
    } catch (e) {
      // If permission denied, return empty list
      if (e.toString().contains('permission-denied')) {
        return [];
      }
      throw Exception('Failed to get users: $e');
    }
  }

  // Get user count by status
  static Future<Map<String, int>> getUserStats() async {
    try {
      // Try to get total users first to check permissions
      final totalUsersSnapshot = await _firestore.collection(_usersCollection).get();
      
      // If successful, proceed with other queries
      final activeUsersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      final inactiveUsersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('isActive', isEqualTo: false)
          .get();
          
      final adminUsersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'admin')
          .get();

      return {
        'total': totalUsersSnapshot.docs.length,
        'active': activeUsersSnapshot.docs.length,
        'inactive': inactiveUsersSnapshot.docs.length,
        'admins': adminUsersSnapshot.docs.length,
      };
    } catch (e) {
      // If permission denied, return default values
      if (e.toString().contains('permission-denied')) {
        return {
          'total': 0,
          'active': 0,
          'inactive': 0,
          'admins': 0,
        };
      }
      throw Exception('Failed to get user stats: $e');
    }
  }

  // Update user status (active/inactive)
  static Future<void> updateUserStatus(String uid, bool isActive) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Update user role
  static Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({'role': role.toString().split('.').last});
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? profilePictureUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (name != null && name.isNotEmpty) updateData['name'] = name;
      if (profilePictureUrl != null) updateData['profilePictureUrl'] = profilePictureUrl;
      
      if (updateData.isNotEmpty) {
        await _firestore
            .collection(_usersCollection)
            .doc(uid)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Delete user (soft delete by deactivating)
  static Future<void> softDeleteUser(String uid) async {
    try {
      await updateUserStatus(uid, false);
    } catch (e) {
      throw Exception('Failed to soft delete user: $e');
    }
  }

  // Hard delete user (permanent deletion)
  static Future<void> hardDeleteUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get recent users (last 7 days)
  static Future<List<UserModel>> getRecentUsers({int limit = 10}) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent users: $e');
    }
  }

  // Search users by name or email
  static Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      // Get all users and filter client-side for now
      // In production, you might want to use Algolia or similar for better search
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('name')
          .limit(100) // Limit to avoid large queries
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .take(limit)
          .toList();

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
