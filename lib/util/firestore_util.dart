import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/mood.dart';

class FirestoreUtil {
  final Firestore _db = Firestore.instance;

  Future<FirestoreUser> getUser(String userID) async {
    return FirestoreUser.fromFirestore(
        (await _db.collection('users').document(userID).get()).data);
  }

  Stream<DocumentSnapshot> getStats(String meUID, String personUID) {
    return _db
        .collection('users')
        .document(personUID)
        .collection('sentMoods')
        .document(meUID)
        .snapshots();
  }

  Future<QuerySnapshot> searchPersonByEmail(String email) {
    return _db
        .collection("users")
        .where('email', isEqualTo: email)
        .getDocuments();
  }

  void sentNotification(FirebaseUser me, FirestoreUser person, Mood moodSent) {
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
      } else {
        await tx.set(
            postRef, <String, dynamic>{moodKey: 1, 'currentMood': moodKey});
      }
    });
  }

  Stream<DocumentSnapshot> getCurrentRelationsSnapshot(String currentUserID) {
    return _db.collection('friends').document(currentUserID).snapshots();
  }

  void sendFriendRequest(String currentUserID, String friendUserID) {
    _db
        .collection('friends')
        .document(currentUserID)
        .setData({friendUserID: 'pending'}, merge: true);

    _db
        .collection('friends')
        .document(friendUserID)
        .setData({currentUserID: 'request'}, merge: true);
  }

  void acceptFriendRequest(String currentUserID, String friendUserID) {
    _db
        .collection('friends')
        .document(currentUserID)
        .setData({friendUserID: 'friend'}, merge: true);

    _db
        .collection('friends')
        .document(friendUserID)
        .setData({currentUserID: 'friend'}, merge: true);
  }

  void rejectFriendRequest(String currentUserID, String friendUserID) {
    _db
        .collection('friends')
        .document(currentUserID)
        .setData({friendUserID: FieldValue.delete()}, merge: true);

    _db
        .collection('friends')
        .document(friendUserID)
        .setData({currentUserID: FieldValue.delete()}, merge: true);
  }

  void stopBeingFriends(String currentUserID, String friendUserID) {
    rejectFriendRequest(currentUserID, friendUserID);
  }
}

final FirestoreUtil firestoreUtil = FirestoreUtil();
