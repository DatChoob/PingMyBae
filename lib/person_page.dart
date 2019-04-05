import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/notification_stats.dart';
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
                      return _showStats(stats);
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

  Widget _showStats(NotificationStats stats) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
        Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(children: <Widget>[
            Text("Happy"),
            IconButton(icon: Icon(FontAwesomeIcons.smileBeam), onPressed: null),
            Text('${stats.happy}')
          ]),
          Column(
            children: <Widget>[
              Text("Attention"),
              IconButton(icon: Icon(FontAwesomeIcons.child), onPressed: null),
              Text('${stats.attention}')
            ],
          ),
          Column(
            children: <Widget>[
              Text("Surprised"),
              IconButton(
                  icon: Icon(FontAwesomeIcons.surprise), onPressed: null),
              Text('${stats.surprised}')
            ],
          ),
          Column(
            children: <Widget>[
              Text("Hangry"),
              IconButton(
                  icon: Icon(FontAwesomeIcons.pizzaSlice), onPressed: null),
              Text('${stats.hangry}')
            ],
          )
        ],
      ),
      SizedBox(width: 10, height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(children: <Widget>[
            Text("Sad"),
            IconButton(icon: Icon(FontAwesomeIcons.sadTear), onPressed: null),
            Text('${stats.sad}'),
          ]),
          Column(
            children: <Widget>[
              Text("Angry"),
              IconButton(icon: Icon(FontAwesomeIcons.angry), onPressed: null),
              Text('${stats.angry}'),
            ],
          ),
          Column(
            children: <Widget>[
              Text("Alone Time"),
              IconButton(
                  icon: Icon(FontAwesomeIcons.userSecret), onPressed: null),
              Text('${stats.alone}'),
            ],
          ),
          Column(
            children: <Widget>[
              Text("Tired"),
              IconButton(icon: Icon(FontAwesomeIcons.tired), onPressed: null),
              Text('${stats.tired}'),
            ],
          )
        ],
      )
    ]);
  }
}
