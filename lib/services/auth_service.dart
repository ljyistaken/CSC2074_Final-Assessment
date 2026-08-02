import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] used by the login, settings, and
/// change-password screens. Also owns the small `users/{uid}` Firestore
/// doc that tracks each account's role ('user' or 'admin') — see
/// firestore.rules for how role changes are locked down server-side.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Emits the current user whenever sign-in state changes (login, logout,
  /// token refresh). `null` means signed out. `AuthGate` in `app.dart`
  /// listens to this to decide which flow to show.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) return;

    if (fullName.trim().isNotEmpty) {
      await user.updateDisplayName(fullName.trim());
      await user.reload();
    }

    // Every account starts as a plain 'user'. Promotion to 'admin' is a
    // deliberate manual step in the Firebase console (Firestore -> Data ->
    // users/{uid} -> set role to 'admin') -- never something the client can
    // do to itself, enforced by firestore.rules.
    await _db.collection('users').doc(user.uid).set({
      'email': email.trim(),
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Re-authenticates with the old password, then sets the new one.
  /// Firebase requires a recent sign-in before allowing a password change,
  /// which is why this can't just call `updatePassword` directly.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw StateError('No signed-in user to update.');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Whether the signed-in user's `users/{uid}` doc has `role == 'admin'`.
  /// Used to gate the "Manage Restaurants" tile in Settings.
  Future<bool> isCurrentUserAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] == 'admin';
  }

  /// Human-readable message for common [FirebaseAuthException] codes so
  /// screens don't need to know Firebase's error-code strings.
  static String messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'requires-recent-login':
        return 'Please log out and log back in, then try again.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}