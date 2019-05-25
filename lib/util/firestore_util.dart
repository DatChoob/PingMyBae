import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pingmybae/models/firestore_user.dart';
import 'package:pingmybae/models/mood.dart';
import 'package:pingmybae/models/mood_reaction.dart';

class FirestoreUtil {
  static const String SENT_MOODS = 'sentMoods';
  static const String FRIENDS = 'friends';
  static const String USERS = 'users';

  final Firestore _db = Firestore.instance;

  Future<FirestoreUser> getUser(String userID) async {
    return FirestoreUser.fromFirestore(
        (await _db.collection('users').document(userID).get()).data);
  }

  Stream<DocumentSnapshot> getStats(String meUID, String friendUID) {
    return _db
        .collection(USERS)
        .document(friendUID)
        .collection(SENT_MOODS)
        .document(meUID)
        .snapshots();
  }

//Future Enahncement: Search via elasticsearch
  Future<List<QuerySnapshot>> searchFriend(String keyword) {
    keyword = keyword.toLowerCase();
    Future<QuerySnapshot> searchEmailFuture =
        _db.collection(USERS).where('email', isEqualTo: keyword).getDocuments();

    Future<QuerySnapshot> searchFirstNameFuture = _db
        .collection(USERS)
        .where('firstName', isEqualTo: keyword)
        .getDocuments();

    Future<QuerySnapshot> searchLastFuture = _db
        .collection(USERS)
        .where('lastName', isEqualTo: keyword)
        .getDocuments();

    return Future.wait(
        [searchEmailFuture, searchFirstNameFuture, searchLastFuture]);
  }

  void sentMoodNotification(
      FirestoreUser me, FirestoreUser friend, Mood moodSent) {
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

  void sentReactionNotification(
      FirestoreUser me, FirestoreUser friend, MoodReaction moodSent) {
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
          'currentReaction': moodKey
        });
      } else {
        await tx.set(
            postRef, <String, dynamic>{moodKey: 1, 'currentReaction': moodKey});
      }
    });
  }

  Stream<DocumentSnapshot> getCurrentRelationsSnapshot(String currentUserID) {
    return _db.collection(FRIENDS).document(currentUserID).snapshots();
  }

  void sendFriendRequest(String currentUserID, String friendUserID) {
    _db
        .collection(FRIENDS)
        .document(currentUserID)
        .setData({friendUserID: 'pending'}, merge: true);

    _db
        .collection(FRIENDS)
        .document(friendUserID)
        .setData({currentUserID: 'request'}, merge: true);
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
