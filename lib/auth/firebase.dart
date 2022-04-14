// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth.dart';

class FirebaseAuthService implements Auth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Future<bool> get isSignedIn => _googleSignIn.isSignedIn();

/*  @override
  User get user {
    return FirebaseUser(_auth.currentUser?.uid ?? "",_auth.currentUser?.photoURL ?? "");
  }*/

  @override
  Future<User> signIn() async {
    try {
      return await _signIn();
    } on PlatformException {
      throw SignInException();
    }
  }

  Future<User> _signIn() async {
    GoogleSignInAccount? googleUser;
    if (await isSignedIn) {
      googleUser = await _googleSignIn.signInSilently();
    } else {
      googleUser = await _googleSignIn.signIn();
    }

    var googleAuth = await googleUser!.authentication;

    var credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    var authResult = await _auth.signInWithCredential(credential);

    return FirebaseUser(
        authResult.user!.uid,
        authResult.user!.displayName,
        authResult.user!.email,
        authResult.user!.photoURL);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

class FirebaseUser extends ChangeNotifier implements User {

  @override String uid;
  @override String? name;
  @override String? email;
  @override String? photoUrl;

  FirebaseUser(this.uid, this.name, this.email, this.photoUrl);

  void updateAndNotify(User newUser) {
    // actualizamos el usuario
    uid = newUser.uid;
    name = newUser.name;
    email = newUser.email;
    photoUrl = newUser.photoUrl;
    //notificamos a los widgets para que se repinten
    notifyListeners();
  }
}
