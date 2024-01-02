import 'package:firebase_auth/firebase_auth.dart';

import 'package:kam/global/common/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      //await saveUserDataLocally(credential.user);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'Poštni naslov je že v uporabi.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      //await saveUserDataLocally(credential.user);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Elektronski naslov ali geslo ni validno.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

  /*Future<void> saveUserDataLocally(User? user) async {
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', user.uid);
      prefs.setString('displayName', user.displayName ?? '');
      prefs.setString('email', user.email ?? '');
      prefs.setString('profileURL', user.photoURL ?? '');
    }
  }*/
}
