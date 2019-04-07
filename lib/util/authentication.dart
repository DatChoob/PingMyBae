import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  // Shared State for Widgets
  BehaviorSubject<FirebaseUser> user = BehaviorSubject();
  // user data in Firestore
  Observable<FirestoreUser> currentLoggedInUser;

  AuthService() {
    user.addStream(_auth.onAuthStateChanged);

    currentLoggedInUser = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .collection('users')
            .document(u.uid)
            .snapshots()
            .map((snap) => FirestoreUser.fromFirestore(snap.data));
      } else {
        return Observable.just(null);
      }
    });
  }

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      // Happens when user cancels google signin
      if (googleUser == null) {
        return null;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = await _auth.signInWithCredential(credential);

      updateUserData(user);

      print("signed in " + user.displayName);
      return user;
    } catch (e) {
      print("Error occured with google sign in");
      print(e);
    }
  }

  Future<void> updateUserData(FirebaseUser user) async {
    String fcmToken = await FirebaseMessaging().getToken();
    DocumentReference ref = _db.collection('users').document(user.uid);

    return await ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'fcmToken': fcmToken,
      'lastSeen': DateTime.now()
    }, merge: true);
  }

  void signOut() {
    _auth.signOut();
    _googleSignIn.signOut();
  }

  Future<void> updateFcmToken(String uid, String fcmToken) {
    return _db
        .collection('users')
        .document(uid)
        .setData({'fcmToken': fcmToken}, merge: true);
  }
}

final AuthService authService = AuthService();
