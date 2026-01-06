import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // adjust import path if needed

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ───────────────────────────────────────────────────────────────
  // 🔹 Start phone verification
  Future<void> verifyPhone({
    required String phone,
    required void Function(PhoneAuthCredential) onAutoVerified,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException) onFailed,
    required void Function(String) onTimeout,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onTimeout,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // 🔹 Sign in with SMS code
  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return await _auth.signInWithCredential(credential);
  }

  // ───────────────────────────────────────────────────────────────
  // 🔹 Post sign-in logic — create or update user record
  // The user model returned from postSignIn now contains the full data
  Future<UserModel> postSignIn(UserCredential userCredential) async {
    final user = userCredential.user;

    if (user == null) {
      throw Exception('User is null after sign-in.');
    }
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userDocRef.get();

    if (userSnapshot.exists) {
      // Existing user: return the data from Firestore.
      return UserModel.fromMap(userSnapshot.data()!, user.uid);
    } else {
      // New user: create a new user and return it.
      final newUser = UserModel(
        id: user.uid,
        userName: user.displayName ?? '',
        firstName: '',
        lastName: '',
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        createdAt: Timestamp.now(),
        bookingCount: 0,
      );
      await userDocRef.set(newUser.toMap());
      return newUser;
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return UserModel.fromMap(data, doc.id);
  }

  // ───────────────────────────────────────────────────────────────
  // 🔹 Auth state helpers

  /// Stream of auth state changes (user or null)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current logged-in Firebase user (synchronous)
  User? get currentUser => _auth.currentUser;

  /// Check if a user is currently logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update user data in Firestore
  Future<void> updateUser(UserModel user) async {
    final userDocRef = _firestore.collection('users').doc(user.id);
    await userDocRef.set(user.toMap(), SetOptions(merge: true));
  }

  /// Check if a user with the given phone number already exists
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // In case of error (e.g. offline), we might want to default to false or rethrow
      // For now, let's log and rethrow to be safe
      print('Error checking user existence: $e');
      rethrow;
    }
  }
}
