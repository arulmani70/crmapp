import 'package:crmapp/src/common/common.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class LoginFirebaseRepository {
  final FirebaseAuth _firebaseAuth;
  final PreferencesRepository prefRepo;
  final ApiRepository apiRepo;

  LoginFirebaseRepository({
    FirebaseAuth? firebaseAuth,
    required this.prefRepo,
    required this.apiRepo,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final log = Logger();
  Future<UsersModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return UsersModel.fromFirebaseUser(firebaseUser);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    log.d("LoginFirebaseRepository :: signOut ");
    await _firebaseAuth.signOut();
  }
}
