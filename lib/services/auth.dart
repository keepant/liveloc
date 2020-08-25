import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<String> getUid();
  Future<String> registerUser(String email, String password, String displayName);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> registerUser(String email, String password, String displayName) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser user = await _firebaseAuth.currentUser();
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = displayName;
      user.updateProfile(updateInfo);
      print('displayName: ${user.displayName}');

    } catch (e) {
      print(e);
    }
    return 'Success register';
  }

  Future<String> signInWithEmail(String email, String password) async {
    String errorMessage;

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your password is wrong.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    FirebaseUser user = await _firebaseAuth.currentUser();
    return await user.getIdToken(refresh: false);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<String> getUid() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    return user.uid;
  }

  Future<String> getName() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    return user.displayName;
  }

  Future<FirebaseUser> getUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    return user;
  }
}

Auth auth = Auth();