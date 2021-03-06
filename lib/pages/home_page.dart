import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pingmybae/models/firestore_user.dart';
import 'package:pingmybae/models/notification_from_message.dart';
import 'package:pingmybae/pages/add_friends_route.dart';
import 'package:pingmybae/pages/friend/friend_page.dart';
import 'package:pingmybae/pages/friend_request_route.dart';

import 'package:pingmybae/util/authentication.dart';
import 'package:pingmybae/util/firestore_util.dart';

class HomePage extends StatefulWidget {
  final FirestoreUser currentUser;
  HomePage({Key key, this.currentUser}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      //android/ios: triggered when in the app in foreground
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      //app in background and user clicks notification from system tray.
      //route user to friend page  or pending requests page
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    int numFriendRequests = widget.currentUser.getFriendRequests().length;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: _confirmLogoutDialog,
        ),
        title: Text('Ping My Bae'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _openAddFriendsPage,
          ),
          numFriendRequests > 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: GestureDetector(
                    child: Chip(
                        label: Text('$numFriendRequests',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.red),
                    onTap: _openPendingFriendRequestsPage,
                  ),
                )
              : Container(width: 0, height: 0)
        ],
      ),
      body: SafeArea(child: _getUsers()),
    );
  }

  _openAddFriendsPage() {
    _navigateToPage(context, AddFriendsRoute(currentUser: widget.currentUser));
  }

  _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  _openPendingFriendRequestsPage() {
    _navigateToPage(
        context, FriendRequestRoute(currentUser: widget.currentUser));
  }

  void _navigateToItemDetail(Map<String, dynamic> message) async {
    final NotifactionFromMessage item =
        NotifactionFromMessage.fromNotification(message);

    if (item.isMoodType) {
      FirestoreUser friend = await firestoreUtil.getUser(item.fromUserID);
      _navigateToPage(
          context,
          FriendPage(
            friend: friend,
            currentUser: widget.currentUser,
          ));
    } else if (item.isFriendRequestType) {
      _navigateToPage(
          context, FriendRequestRoute(currentUser: widget.currentUser));
    }
  }

  _getUsers() {
    List<Future<FirestoreUser>> futureFriendList =
        widget.currentUser.getFriends();
    if (futureFriendList.isEmpty) {
      return Center(
          child: Text("You have no friends. Go and add your friends"));
    } else {
      return FutureBuilder(
          future: Future.wait(futureFriendList),
          builder: (BuildContext context,
              AsyncSnapshot<List<FirestoreUser>> allUsersSnapshot) {
            if (allUsersSnapshot.hasData) {
              List<FirestoreUser> users = allUsersSnapshot.data;
              return ListView(
                  children: users
                      .map((user) =>
                          firestoreUserToFriendListTile(user, context))
                      .toList());
            } else
              return Center(child: CircularProgressIndicator());
          });
    }
  }

  ListTile firestoreUserToFriendListTile(
      FirestoreUser user, BuildContext context) {
    return ListTile(
        title: Text(user.displayName),
        leading: Hero(
          tag: "hero.${user.uid}",
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(user.photoURL, width: 55),
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () => navigateToFirstPage(context, user));
  }

  void navigateToFirstPage(BuildContext context, FirestoreUser user) {
    _navigateToPage(
      context,
      FriendPage(friend: user, currentUser: widget.currentUser),
    );
  }

  void _confirmLogoutDialog() async {
    bool logout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log out"),
          content: Text("Are you sure you want to logout?"),
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
    if (logout == true) {
      authService.signOut();
    }
  }
}
