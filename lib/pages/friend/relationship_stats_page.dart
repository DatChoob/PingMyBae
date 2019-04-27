import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/notification_stats.dart';
import 'package:ping_friends/pages/friend/friend_mood_stats.dart';
import 'package:ping_friends/pages/friend/friend_reaction_stats.dart';
import 'package:ping_friends/util/firestore_util.dart';

class RelationshipStatsPage extends StatefulWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  const RelationshipStatsPage({Key key, this.friend, this.currentUser})
      : super(key: key);

  @override
  _RelationshipStatsPageState createState() => _RelationshipStatsPageState();
}

class _RelationshipStatsPageState extends State<RelationshipStatsPage> {
  NotificationStats statsFromFriend = NotificationStats.empty();
  StreamSubscription<DocumentSnapshot> statsFromFriendStreamSubscription;
  NotificationStats statsToFriend = NotificationStats.empty();
  StreamSubscription<DocumentSnapshot> statsToFriendStreamSubscription;
  @override
  void initState() {
    super.initState();
    statsFromFriendStreamSubscription = firestoreUtil
        .getStats(widget.currentUser.uid, widget.friend.uid)
        .listen((onData) => setState(() {
              statsFromFriend = onData.exists
                  ? NotificationStats.fromFirebase(onData.data)
                  : NotificationStats.empty();
            }));
    statsToFriendStreamSubscription = firestoreUtil
        .getStats(widget.friend.uid, widget.currentUser.uid)
        .listen((onData) => setState(() {
              statsToFriend = onData.exists
                  ? NotificationStats.fromFirebase(onData.data)
                  : NotificationStats.empty();
            }));
  }

  @override
  void dispose() {
    super.dispose();
    statsFromFriendStreamSubscription.cancel();
    statsToFriendStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(widget.friend.photoURL)),
          SizedBox(width: 10),
          Text("${widget.friend.displayName}")
        ])),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _showDialogStopBeingFriends,
          )
        ],
      ),
      body: SafeArea(
        child: ListView(children: [
          Column(
            children: <Widget>[
              Text("From ${widget.friend.displayName}",
                  style: TextStyle(fontSize: 30)),
              FriendMoodStats(stats: statsFromFriend),
              FriendReactionStats(stats: statsFromFriend),
              Divider(height: 50),
              Text("To ${widget.currentUser.displayName}",
                  style: TextStyle(fontSize: 30)),
              FriendMoodStats(stats: statsToFriend),
              FriendReactionStats(stats: statsToFriend),
            ],
          )
        ]),
      ),
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
      Navigator.of(context).pop('removeFriend');
    }
  }
}
