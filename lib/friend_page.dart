import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/notification_stats.dart';
import 'package:ping_friends/friend_stats.dart';
import 'package:ping_friends/radial_menu.dart';
import 'package:ping_friends/util/firestore_util.dart';

class FriendPage extends StatefulWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  FriendPage({Key key, this.friend, this.currentUser}) : super(key: key);

  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friend.displayName}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _showDialogStopBeingFriends,
          )
        ],
      ),
      body: Column(children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Hero(
              tag: "hero.${widget.friend.uid}",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(widget.friend.photoURL),
              ),
            ),
          ),
        ),
        StreamBuilder(
            stream: firestoreUtil.getStats(
                widget.currentUser.uid, widget.friend.uid),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              NotificationStats stats = snapshot.hasData
                  ? NotificationStats.fromFirebase(snapshot.data.data)
                  : NotificationStats.empty();
              return FriendStats(stats: stats);
            }),
        Expanded(child: Center(child: RadialMenu(friend: widget.friend)))
      ]),
    );
  }

  void _showDialogStopBeingFriends() async {
    bool removeFriend = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Removing friend"),
          content:
              Text("Stop being friends with ${widget.friend.displayName}?"),
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
    if (removeFriend == true) {
      firestoreUtil.stopBeingFriends(widget.currentUser.uid, widget.friend.uid);
      Navigator.of(context).pop();
    }
  }
}
