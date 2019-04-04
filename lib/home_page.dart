import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ping_friends/person_page.dart';
import 'package:ping_friends/util/authentication.dart';
import 'package:ping_friends/util/firestore_util.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({Key key, this.userId}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Ping My Friends Home Page'),
          leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: authService.signOut,
          )),
      body: _getUsers(),
    );
  }

  _getUsers() {
    return StreamBuilder(
      stream: FirestoreUtil().getUsers(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView(
            itemExtent: 100,
            children: snapshot.data.documents.map((document) {
              FirestoreUser user = FirestoreUser.fromFirestore(document.data);
              return ListTile(
                leading: Hero(
                  tag: "hero.${user.uid}",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(user.photoURL),
                  ),
                ),
                title: Text(
                  user.displayName,
                ),
                onTap: () {
                  // sendNotification(user);
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PersonPage(person: user);
                  }));
                },
              );
            }).toList(),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
