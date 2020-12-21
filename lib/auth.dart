import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseAuth {

  Future<String> currentUser();
  Future<String> signIn(String email, String password);
  Future<String> createUser(String email, String password, String name);
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final firestoreInstance = Firestore.instance;

  Future<String> signIn(String email, String password) async {
    AuthResult user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.additionalUserInfo.providerId;
  }

  Future<String> createUser(String email, String password, String name) async {
    AuthResult user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    String uid = await currentUser();
    firestoreInstance.collection("Users").document(uid).setData({
      "name": name,
      "nameKey": name[0],
      "email": email,
    }).then((value) {

    });
    return user.additionalUserInfo.providerId;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

}