import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // Create or update user document in Firestore
  static Future<void> createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? profilePictureUrl,
    UserRole role = UserRole.user,
  }) async {
    try {
      final userDoc = _firestore.collection(_usersCollection).doc(uid);
      
      // Check if user already exists
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        // Create new user document
        final userData = UserModel(
          uid: uid,
          email: email,
          name: name,
          profilePictureUrl: profilePictureUrl,
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await userDoc.set(userData.toFirestore());
      } else {
        // Update last login time for existing user
        await userDoc.update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user document from Firestore
  static Future<UserModel?> getUserDocument(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  // Update user document
  static Future<void> updateUserDocument({
    required String uid,
    String? name,
    String? profilePictureUrl,
    UserRole? role,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (profilePictureUrl != null) updateData['profilePictureUrl'] = profilePictureUrl;
      if (role != null) updateData['role'] = role.toString().split('.').last;
      
      if (updateData.isNotEmpty) {
        await _firestore
            .collection(_usersCollection)
            .doc(uid)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  // Delete user document
  static Future<void> deleteUserDocument(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user document: $e');
    }
  }

  // Check if user exists
  static Future<bool> userExists(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  // Get all users (admin functionality)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Stream user document for real-time updates
  static Stream<UserModel?> streamUserDocument(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
      return null;
    });
  }
}
