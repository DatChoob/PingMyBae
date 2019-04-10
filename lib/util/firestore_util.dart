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

  final String SENT_MOODS = 'sentMoods';
  final String FRIENDS = 'friends';
  final String USERS = 'users';

  Stream<DocumentSnapshot> getStats(String meUID, String friendUID) {
    return _db
        .collection(USERS)
        .document(friendUID)
        .collection(SENT_MOODS)
        .document(meUID)
        .snapshots();
  }

  Future<QuerySnapshot> searchFriendByEmail(String email) {
    return _db
        .collection(USERS)
        .where('email', isEqualTo: email)
        .getDocuments();
  }

  void sentNotification(FirebaseUser me, FirestoreUser friend, Mood moodSent) {
    final DocumentReference postRef = _db
        .collection(USERS)
        .document(me.uid)
        .collection(SENT_MOODS)
        .document(friend.uid);
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
    return _db.collection(FRIENDS).document(currentUserID).snapshots();
  }

  void sendFriendRequest(String currentUserID, String friendUserID) {
    _sendFriendRequest(currentUserID, friendUserID);
    _sendFriendRequest(friendUserID, currentUserID);
  }

  _sendFriendRequest(String documentID, String friendUserID) {
    _db
        .collection(FRIENDS)
        .document(documentID)
        .setData({friendUserID: 'request'}, merge: true);
  }

  void acceptFriendRequest(String currentUserID, String friendUserID) {
    _acceptFriendRequest(currentUserID, friendUserID);
    _acceptFriendRequest(friendUserID, currentUserID);
  }

  _acceptFriendRequest(String documentID, String friendUserID) {
    _db
        .collection(FRIENDS)
        .document(documentID)
        .setData({friendUserID: 'friend'}, merge: true);
  }

  void rejectFriendRequest(String currentUserID, String friendUserID) {
    _rejectFriendRequest(currentUserID, friendUserID);
    _rejectFriendRequest(friendUserID, currentUserID);
  }

  void _rejectFriendRequest(String documentID, String friendUserID) {
    _db
        .collection(FRIENDS)
        .document(documentID)
        .setData({friendUserID: FieldValue.delete()}, merge: true);
  }

  void stopBeingFriends(String currentUserID, String friendUserID) {
    rejectFriendRequest(currentUserID, friendUserID);

    //remove the SENT_MOODS from both users
    _removeSentMoods(currentUserID, friendUserID);
    _removeSentMoods(friendUserID, currentUserID);
  }

  void _removeSentMoods(String documentID, String friendUserID) {
    _db
        .collection(USERS)
        .document(documentID)
        .collection(SENT_MOODS)
        .document(friendUserID)
        .delete()
        .then((val) {});
  }
}

final FirestoreUtil firestoreUtil = FirestoreUtil();
