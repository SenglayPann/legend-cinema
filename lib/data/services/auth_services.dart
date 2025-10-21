import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Start phone verification
  Future<void> verifyPhone({
    required String phone,
    required void Function(PhoneAuthCredential) onAutoVerified,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException) onFailed,
    required void Function(String) onTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatic verification (Android)
        onAutoVerified(credential);
      },
      verificationFailed: (e) => onFailed(e),
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        onTimeout(verificationId);
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Sign in with SMS code
  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential;
  }

  // After sign-in: custom logic
  Future<void> postSignIn(UserCredential userCredential) async {
    final user = userCredential.user;
    final additional = userCredential.additionalUserInfo;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    if (additional != null && additional.isNewUser) {
      // New user sign-up flow
      await userDoc.set({
        'phone': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
      // navigate to onboarding / profile complete
    } else {
      // Existing user: maybe fetch data
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        // fallback: create record
        await userDoc.set({
          'phone': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    // You can also mint custom tokens, call cloud functions, etc.
  }
}
