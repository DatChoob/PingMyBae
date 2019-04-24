import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/notification_stats.dart';
import 'package:ping_friends/pages/friend/friend_mood_stats.dart';
import 'package:ping_friends/pages/friend/friend_reaction_stats.dart';
import 'package:ping_friends/pages/friend/radial_menu/mood_radial_menu.dart';
import 'package:ping_friends/pages/friend/radial_menu/reaction_radial_menu.dart';
import 'package:ping_friends/util/firestore_util.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class FriendPage extends StatefulWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  FriendPage({Key key, this.friend, this.currentUser}) : super(key: key);

  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  NotificationStats stats = NotificationStats.empty();
  StreamSubscription<DocumentSnapshot> statsStreamSubscription;
  @override
  void initState() {
    super.initState();
    statsStreamSubscription = firestoreUtil
        .getStats(widget.currentUser.uid, widget.friend.uid)
        .listen((onData) {
      setState(() {
        stats = onData.exists
            ? NotificationStats.fromFirebase(onData.data)
            : NotificationStats.empty();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    statsStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Hero(
            tag: "hero.${widget.friend.uid}",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(widget.friend.photoURL),
            ),
          ),
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
          child: Container(
              child: SwipableResponses(
                  currentUser: widget.currentUser,
                  friend: widget.friend,
                  stats: stats))),
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

class SwipableResponses extends StatefulWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  final NotificationStats stats;

  SwipableResponses({Key key, this.friend, this.currentUser, this.stats})
      : super(key: key);
  @override
  _SwipableResponsesState createState() => _SwipableResponsesState();
}

class _SwipableResponsesState extends State<SwipableResponses> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return index == 0
            ? Column(children: [
                FriendMoodStats(stats: widget.stats),
                Expanded(
                    child: Center(
                        child: MoodRadialMenu(
                            friend: widget.friend,
                            currentUser: widget.currentUser)))
              ])
            : Column(children: [
                FriendReactionStats(stats: widget.stats),
                Expanded(
                    child: Center(
                        child: ReactionRadialMenu(
                            friend: widget.friend,
                            currentUser: widget.currentUser)))
              ]);
      },
      itemCount: 2,
      pagination: SwiperPagination(builder: SwiperPagination.dots),
      control: SwiperControl(),
    );
  }

  final String serverKey =
      "AAAAuZeUo-s:APA91bHtlAXklqXnuCnPlcu_F01KJa38jtytOHODZuBlf56Z7B6upzbrYZaGx_hBJeKxMgsNuWfa3-X7GGyeUkMpLn6Yyy-729Y43R_hTI0FCjI5ahhenOn9vCbadUSQOdIMl0ek17my";
}
