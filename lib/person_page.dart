import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_friends/models/notification_stats.dart';
import 'package:ping_friends/person_stats.dart';
import 'package:ping_friends/radial_menu.dart';
import 'package:ping_friends/util/authentication.dart';
import 'package:ping_friends/util/firestore_util.dart';

class PersonPage extends StatefulWidget {
  final FirestoreUser person;
  PersonPage({Key key, this.person}) : super(key: key);

  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  @override
  Widget build(BuildContext context) {
    print("hello hero.${widget.person.uid}");
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.person.displayName}"),
      ),
      body: Column(children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Hero(
              tag: "hero.${widget.person.uid}",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(widget.person.photoURL),
              ),
            ),
          ),
        ),
        FutureBuilder(
            future: authService.user.first,
            builder: (BuildContext context,
                AsyncSnapshot<FirebaseUser> currentUserAsync) {
              if (currentUserAsync.hasData) {
                FirebaseUser currentUser = currentUserAsync.data;
                print(currentUser.uid);
                return StreamBuilder(
                    stream: FirestoreUtil()
                        .getStats(currentUser.uid, widget.person.uid),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      NotificationStats stats = snapshot.hasData
                          ? NotificationStats.fromFirebase(snapshot.data.data)
                          : NotificationStats.empty();
                      return PersonStats(stats: stats);
                    });
              } else
                return Container();
            }),
        Expanded(
          child: Center(
            child: RadialMenu(person: widget.person),
          ),
        ),
      ]),
    );
  }
}
