import 'package:groupchat/Authenticate/LoginScree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//CREATE CREATEACCOUNT FUNCTION....
Future<User?> createAccount(String name, String email, String password) async {

  //THIS IS FOR CALL FIREBASE FUNCTION
  FirebaseAuth _auth = FirebaseAuth.instance;


  //THIS IS FOR STORING THE DATA IN CLOUD STORE OF FIREBASE
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //THIS ONE IS CREATE ACCOUNT USING EMAIL AND PASSWORD AND IF GET ERROR THEN SOLVE USING TRY AND CATCH
  try {
    UserCredential userCrendetial = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    print("Account created Succesfull");

    userCrendetial.user!.updateDisplayName(name);

    // collection = IT COLLECT DATA WHICH IS ENTER BY USER & IT WILL BE STORE IN FIREBASE AS A USERS(FOLDER)
    // uid = UNIQUE ID GIVEN BY FIREBASE WHEN USER CREATE ACCOUNT
    // set = IT IS METHOD IN WHICH STORE IN FIREBASE ..HERE NAME , EMAIL AND STATUS....
    await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "status": "Unavalible",
      "uid": _auth.currentUser!.uid,
    });

    return userCrendetial.user;
  } catch (e) {
    print(e);
    return null;
  }
}

//CREATE LOGIN FUNCTION
Future<User?> logIn(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    print("Login Sucessfull");
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => userCredential.user!.updateDisplayName(value['name']));

    return userCredential.user;
  } catch (e) {
    print(e);
    return null;
  }
}

//THIS IS FOR LOGOUT...
Future logOut(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    await _auth.signOut().then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  } catch (e) {
    print("error");
  }
}
