import 'package:fb_glogin/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fb_glogin/main.dart';
import 'package:get/get.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final databaseReference = Firestore.instance;

Future<String> signInWithGoogle() async {

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

//var customerinfo = databaseReference.collection("users").where("email", isEqualTo: currentUser.email);

  DocumentReference documentReference =
      databaseReference.collection("users").document(currentUser.email);
  documentReference.get().then((datasnapshot) {
    if (datasnapshot.exists) {
      print(currentUser.email);
    } else {
      databaseReference.collection("users").document(currentUser.email).setData(
          {'name': currentUser.displayName, 'picture': currentUser.photoUrl});
    }
  });

  return 'signInWithGoogle succeeded: $user';
  


  
}

Future getCurrentUser() async {
try {
FirebaseUser _user = await FirebaseAuth.instance.currentUser();
print("User: ${_user.displayName ?? "None"}");
return _user;
}catch(e){print ("error with getCurrentUser");}
}

signOutGoogle() async {
  await googleSignIn.signOut();
  print("logout done");
}
