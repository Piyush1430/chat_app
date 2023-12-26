import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthServices {
  Future<UserCredential> signInWithGoogle() async {
    //begin interative sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    //obtain auth deatils from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    //create new credential fro a user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;
    if (user != null) {
      //for storing user deatils in firestore
      await FirebaseFirestore.instance
          .collection("user")
          .doc(userCredential.user!.uid)
          .set({
        "username": user.displayName,
        "e-mail": user.email,
        "image-url": user.photoURL,
      });
    }
    return userCredential;
  }

  Future<String?> signInWithFacebook() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final instance = FacebookAuth.instance;
      final result = await instance
          .login(permissions: ["id", "email", "name", "public_profile"]);
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final a = await auth.signInWithCredential(credential);
        await instance.getUserData().then((userData) async {
          User? user = a.user;
          if (user != null) {
            //for storing user deatils in firestore
            await FirebaseFirestore.instance
                .collection("user")
                .doc(user.uid)
                .set({
              "username": user.displayName,
              "e-mail": user.email,
              "image-url": user.photoURL,
            });
          }
        });
        return null;
      } else if (result.status == LoginStatus.cancelled) {
        return 'Login cancelled';
      } else {
        return 'Error';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
