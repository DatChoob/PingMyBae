import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingmybae/util/firestore_util.dart';

class FirestoreUser {
  String uid;
  String email;
  String photoURL;
  String displayName;
  String fcmToken;
  DateTime lastSeen;
  Map<String, dynamic> currentRelations;

  FirestoreUser(
      {this.uid,
      this.email,
      this.photoURL,
      this.displayName,
      this.fcmToken,
      this.lastSeen,
      this.currentRelations});

  List<Future<FirestoreUser>> getFriends() {
    return currentRelations.entries
        .where((MapEntry<String, dynamic> entry) => entry.value == 'friend')
        .map((MapEntry<String, dynamic> entry) =>
            firestoreUtil.getUser(entry.key))
        .toList();
  }

  List<Future<FirestoreUser>> getFriendRequests() {
    return currentRelations.entries
        .where((MapEntry<String, dynamic> entry) => entry.value == 'request')
        .map((MapEntry<String, dynamic> entry) =>
            firestoreUtil.getUser(entry.key))
        .toList();
  }

  toJson() {
    return {
      'uid': uid,
      'email': email,
      'photoURL': photoURL,
      'displayName': displayName,
      'fcmToken': fcmToken,
      'lastSeen': lastSeen
    };
  }

  static fromFirebaseLogin(FirebaseUser user, String fcmToken) {
    return FirestoreUser(
        uid: user.uid,
        email: user.email,
        photoURL: user.photoUrl,
        displayName: user.displayName,
        fcmToken: fcmToken);
  }

  static fromFirestore(Map<String, dynamic> map) {
    if (map == null) return null;
    return FirestoreUser(
        uid: map['uid'],
        email: map['email'],
        photoURL: map['photoURL'],
        displayName: map['displayName'],
        fcmToken: map['fcmToken'],
        lastSeen: Platform.isIOS
            ? (map['lastSeen'] as Timestamp).toDate()
            : (map['lastSeen'] as DateTime));
  }
}
