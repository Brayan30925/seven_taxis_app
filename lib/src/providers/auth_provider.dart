import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyAuthProvider {
  final FirebaseAuth _firebaseAuth;

  MyAuthProvider() : _firebaseAuth = FirebaseAuth.instance;

  User? getUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  Future<void> checkIfUserIsLogged(BuildContext context, String typeUser,String isNotification) async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      if (isNotification != 'true') {
        if (typeUser == 'client') {
          Navigator.pushNamedAndRemoveUntil(
              context, 'client/map', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, 'driver/map', (route) => false);
        }
        print('Usuario está logueado');
      } else {
        print('Usuario no está logueado');
      }
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (error) {
      print('Error en registro: $error');
      return Future.error((error as FirebaseAuthException).code);
    }
  }

  Future<String?> loginConPass(String email, String pass) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: pass);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print('Error en loginConPass: $e');
      return null;
    }
  }

  Future<bool> existsInCollection(String collectionName, String id) async {
    try {
      CollectionReference collectionRef = FirebaseFirestore.instance.collection(collectionName);
      DocumentSnapshot documentSnapshot = await collectionRef.doc(id).get();
      return documentSnapshot.exists;
    } catch (e) {
      print('Error al verificar la existencia del documento: $e');
      return false;
    }
  }
}
