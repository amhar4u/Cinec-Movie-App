import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  admin,
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePictureUrl,
    this.role = UserRole.user,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  // Generate default profile picture (first letter of name with solid background)
  String get defaultProfilePicture {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    // Using a simple URL with first letter - you can replace this with a service like DiceBear
    return 'https://ui-avatars.com/api/?name=$firstLetter&background=random&color=fff&size=200';
  }

  // Get the profile picture URL (default if none provided)
  String get displayProfilePicture => profilePictureUrl ?? defaultProfilePicture;

  // Create from Firebase document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.user,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? email,
    String? name,
    String? profilePictureUrl,
    UserRole? role,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role)';
  }
}
