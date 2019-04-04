import 'package:flutter/material.dart';
import 'package:ping_friends/radial_menu.dart';
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
            margin: const EdgeInsets.only(top: 20.0),
            child: Hero(
              tag: "hero.${widget.person.uid}",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(widget.person.photoURL),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: RadialMenu(person: widget.person),
          ),
        ),
      ]),
    );
  }
}
