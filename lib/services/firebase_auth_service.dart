import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Email/password and Google sign-in via Firebase Auth.
abstract final class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _google = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates a Firebase user, sets optional [displayName], sends verification email.
  static Future<UserCredential> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty && cred.user != null) {
      await cred.user!.updateDisplayName(name);
      await cred.user!.reload();
    }
    if (cred.user != null && !cred.user!.emailVerified) {
      await cred.user!.sendEmailVerification();
    }
    return cred;
  }

  static Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) {
      return null;
    }
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    await Future.wait<void>([
      _auth.signOut(),
      _google.signOut(),
    ]);
  }

  static String userDisplayLabel(User? user) {
    if (user == null) return 'Farmer';
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'Farmer';
  }
}
