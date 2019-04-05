import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_friends/models/mood.dart';

class FirestoreUtil {
  final Firestore _db = Firestore.instance;

  Stream<QuerySnapshot> getUsers() {
    return _db.collection('users').snapshots();
  }

  Stream<DocumentSnapshot> getStats(String meUID, String personUID) {
    return _db
        .collection('users')
        .document(meUID)
        .collection('sentMoods')
        .document(personUID)
        .snapshots();
  }

  sentNotification(FirebaseUser me, FirestoreUser person, Mood moodSent) {
    final DocumentReference postRef = _db
        .collection('users')
        .document(me.uid)
        .collection('sentMoods')
        .document(person.uid);
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      String moodKey = '${moodSent.type}';
      if (postSnapshot.exists) {
        await tx.update(postRef, <String, dynamic>{
          moodKey: (postSnapshot.data[moodKey] ?? 0) + 1,
          'currentMood': moodKey
        });
        print("updating mood in firebase");
      } else {
        await tx.set(
            postRef, <String, dynamic>{moodKey: 1, 'currentMood': moodKey});
        print("creating mood in firebase");
      }
    });
  }
}

class FirestoreUser {
  String uid;
  String email;
  String photoURL;
  String displayName;
  String fcmToken;
  DateTime lastSeen;

  FirestoreUser(
      {this.uid,
      this.email,
      this.photoURL,
      this.displayName,
      this.fcmToken,
      this.lastSeen});

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
    return FirestoreUser(
        uid: map['uid'],
        email: map['email'],
        photoURL: map['photoURL'],
        displayName: map['displayName'],
        fcmToken: map['fcmToken'],
        lastSeen: Platform.isIOS
            ? (map['lastSeen'] as Timestamp).toDate()
            : (map['lastSeen'] as DateTime));
    ;
  }
}
