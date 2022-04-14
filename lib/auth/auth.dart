// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

abstract class Auth {
  Future<bool> get isSignedIn;
 // User get user;
  Future<User> signIn();
  Future signOut();
}

abstract class User {
  String get uid;
  String? get name; //new
  String? get email; //new
  String? get photoUrl; //new
}

class SignInException implements Exception {}
