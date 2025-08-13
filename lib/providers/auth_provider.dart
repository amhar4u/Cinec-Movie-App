import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
    
    // Initialize authentication state
    _initializeAuthState();
  }

  // Initialize authentication state on app start
  Future<void> _initializeAuthState() async {
    final shouldStayLoggedIn = await PreferencesService.shouldStayLoggedIn();
    if (!shouldStayLoggedIn && _auth.currentUser != null) {
      // If remember me is false but user is still signed in Firebase, sign them out
      await _auth.signOut();
    }
  }

  // Load user model from Firestore
  Future<void> _loadUserModel(String uid) async {
    try {
      _userModel = await FirestoreService.getUserDocument(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  // Email and Password Sign Up
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      if (userCredential.user != null) {
        await FirestoreService.createUserDocument(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          role: UserRole.user, // Default role is user
        );
        
        // Load the user model
        await _loadUserModel(userCredential.user!.uid);
      }
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Email and Password Sign In
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _setLoading(true);
      clearError();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load the user model
      if (_auth.currentUser != null) {
        await _loadUserModel(_auth.currentUser!.uid);
        
        // Save login state if remember me is checked
        await PreferencesService.saveLoginState(
          isLoggedIn: true,
          rememberMe: rememberMe,
          userEmail: email,
        );
      }
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Google Sign In - Temporarily disabled for web
  Future<bool> signInWithGoogle() async {
    _setError('Google Sign-In is temporarily disabled. Please use email/password authentication.');
    return false;
  }

  // Apple Sign In
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      clearError();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        String displayName = userCredential.user!.displayName ?? 'User';
        if (appleCredential.givenName != null && appleCredential.familyName != null) {
          displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
        }

        await FirestoreService.createUserDocument(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: displayName,
          role: UserRole.user,
        );
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Apple sign-in failed. Please try again.');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // await _googleSignIn.signOut(); // Temporarily disabled for web
      _userModel = null;
      
      // Clear login preferences
      await PreferencesService.clearLoginState();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? profilePictureUrl,
  }) async {
    try {
      _setLoading(true);
      clearError();

      if (_user != null) {
        // Update Firebase Auth profile if name is provided
        if (name != null) {
          await _user!.updateDisplayName(name);
        }

        // Update Firestore document
        await FirestoreService.updateUserDocument(
          uid: _user!.uid,
          name: name,
          profilePictureUrl: profilePictureUrl,
        );

        // Reload user model
        await _loadUserModel(_user!.uid);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
      return false;
    }
  }

  // Change user password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      clearError();

      if (_user == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      // Reauthenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );

      await _user!.reauthenticateWithCredential(credential);

      // Update password
      await _user!.updatePassword(newPassword);

      _setLoading(false);
      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } on FirebaseAuthException catch (e) {
      String message = _getFirebaseErrorMessage(e);
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      }
      _setError(message);
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      _setError('Failed to change password. Please try again.');
      return {
        'success': false,
        'message': 'Failed to change password. Please try again.',
      };
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      clearError();

      await _auth.sendPasswordResetEmail(email: email);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Failed to send reset email. Please try again.');
      return false;
    }
  }

  // Refresh user data from Firestore
  Future<void> refreshUser() async {
    if (_user != null) {
      await _loadUserModel(_user!.uid);
    }
  }

  // Get user-friendly error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'invalid-credential':
        return 'The authentication credential is malformed or has expired.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'configuration-not-found':
        return 'Firebase configuration error. Please contact support.';
      case 'api-key-not-valid':
        return 'API key not valid. Please contact support.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication. Please contact support.';
      case 'invalid-api-key':
        return 'Invalid API key. Please contact support.';
      case 'project-not-found':
        return 'Firebase project not found. Please contact support.';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error occurred'}';
    }
  }
}
