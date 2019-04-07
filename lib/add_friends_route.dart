import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm_push/fcm_push.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/util/firestore_util.dart';

class AddFriendsRoute extends StatefulWidget {
  final FirestoreUser currentUser;

  AddFriendsRoute({this.currentUser});
  @override
  _AddFriendsRouteState createState() => _AddFriendsRouteState();
}

class _AddFriendsRouteState extends State<AddFriendsRoute> {
  String _searchKeywords = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Add Friends")),
        body: Column(children: [
          Row(children: <Widget>[
            Flexible(
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: 'Search For People',
                        labelText: 'Search'),
                    onFieldSubmitted: (String value) =>
                        setState(() => _searchKeywords = value)))
          ]),
          Flexible(
              child: FutureBuilder(
                  future: firestoreUtil.searchPersonByEmail(_searchKeywords),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        return ListView(
                            children: snapshot.data.documents
                                .map((documentSnapshot) => _personRowCard(
                                    documentSnapshot.data, context))
                                .toList());
                      } else {
                        return Container(child: Text("No Data Returned"));
                      }
                    } else {
                      return Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    }
                  }))
        ]));
  }

  ListTile _personRowCard(Map<String, dynamic> data, BuildContext context) {
    FirestoreUser friend = FirestoreUser.fromFirestore(data);
// if already friend.  add a check mark stating already friend.
// clicking on tile should pop dialog. Name is already your friend.
// if request already sent. add a pending status mark.
// clicking on tile should pop dialog. Waiting on Name to accept your request
// else. clicking on tile should popup dialog. Would you like to send a friend request? yes/no
    Map<String, dynamic> currentFriends = widget.currentUser.currentRelations;

    bool isFriendAlready = false;
    bool hasRequestedToBeFriend = false;
    if (currentFriends?.containsKey(friend.uid) == true) {
      isFriendAlready = currentFriends[friend.uid] == 'friend';
      hasRequestedToBeFriend = currentFriends[friend.uid] == 'request';
    }

    return ListTile(
        leading: Hero(
          tag: "hero.${friend.uid}",
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(friend.photoURL, width: 55),
          ),
        ),
        title: Text(friend.displayName),
        trailing: isFriendAlready
            ? Icon(Icons.check, color: Colors.green)
            : hasRequestedToBeFriend
                ? Icon(FontAwesomeIcons.question, color: Colors.yellow)
                : null,
        onTap: () {
          isFriendAlready
              ? tellUserIsAlreadyAFriend(friend)
              : hasRequestedToBeFriend
                  ? tellUserAlreadyRequestedAsFriend(friend)
                  : addFriend(friend, context);
        });
  }

  void addFriend(FirestoreUser friend, BuildContext context) async {
    bool addUserAsFriend = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Adding a friend"),
          content: Text(
              "Would you like to send a friend request to ${friend.displayName}?"),
          actions: <Widget>[
            FlatButton(
                child: Text("Yes"),
                onPressed: () => Navigator.of(context).pop(true)),
            FlatButton(
              child: Text("No"),
              onPressed: () => Navigator.of(context).pop(false),
            )
          ],
        );
      },
    );
    if (addUserAsFriend == true) {
      firestoreUtil.sendFriendRequest(widget.currentUser.uid, friend.uid);
      sendFCMNotificationOfRequestSend(widget.currentUser, friend);
      Navigator.of(context).pop();
    }
  }

  void tellUserIsAlreadyAFriend(FirestoreUser friend) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Text("${friend.displayName} is already your friend"),
              actions: <Widget>[
                FlatButton(
                    child: Text("Okay"),
                    onPressed: () => Navigator.of(context).pop())
              ]);
        });
  }

  void tellUserAlreadyRequestedAsFriend(FirestoreUser friend) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Text("Friend Request has already been sent"),
              actions: <Widget>[
                FlatButton(
                    child: Text("Okay"),
                    onPressed: () => Navigator.of(context).pop())
              ]);
        });
  }

  final String serverKey =
      "AAAAuZeUo-s:APA91bHtlAXklqXnuCnPlcu_F01KJa38jtytOHODZuBlf56Z7B6upzbrYZaGx_hBJeKxMgsNuWfa3-X7GGyeUkMpLn6Yyy-729Y43R_hTI0FCjI5ahhenOn9vCbadUSQOdIMl0ek17my";

  void sendFCMNotificationOfRequestSend(
      FirestoreUser currentUser, FirestoreUser friend) async {
    final FCM fcm = FCM(serverKey);
    final Message fcmMessage = Message()
      ..to = friend.fcmToken
      ..title = currentUser.displayName
      ..body = "${currentUser.displayName} has sent you a friend request";

    // fcmMessage.data.add(Tuple2("type", mood.type));
    fcmMessage.data.add(Tuple2("fromUser", currentUser.uid));

    await fcm.send(fcmMessage);
  }
}
