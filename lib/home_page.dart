import 'package:flutter/material.dart';
import 'package:ping_friends/add_friends_route.dart';
import 'package:ping_friends/friend_request_route.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/person_page.dart';
import 'package:ping_friends/util/authentication.dart';

class HomePage extends StatefulWidget {
  final FirestoreUser currentUser;
  HomePage({Key key, this.currentUser}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ping My Friends Home Page')),
      drawer: new LoggedInDrawer(
        currentUser: widget.currentUser,
      ),
      body: _getUsers(),
    );
  }

  _getUsers() {
    List<Future<FirestoreUser>> futureFriendList =
        widget.currentUser.getFriends();
    if (futureFriendList.isEmpty) {
      return Center(
          child: Text("You have no friends. Go and add your friends"));
    } else {
      return ListView(
          children: futureFriendList.map((Future<FirestoreUser> userFuture) {
        return FutureBuilder(
            future: userFuture,
            builder: (BuildContext context,
                AsyncSnapshot<FirestoreUser> userSnapshot) {
              if (userSnapshot.hasData) {
                FirestoreUser user = userSnapshot.data;
                return ListTile(
                    title: Text(user.displayName),
                    leading: Hero(
                        tag: "hero.${user.uid}",
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(user.photoURL, width: 55))),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PersonPage(
                                    person: user,
                                    currentUser: widget.currentUser,
                                  )));
                    });
              } else
                return Center(child: CircularProgressIndicator());
            });
      }).toList());
    }
  }
}

class LoggedInDrawer extends StatelessWidget {
  final FirestoreUser currentUser;
  LoggedInDrawer({Key key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int numFriendRequests = currentUser.getFriendRequests().length;
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
          child: Row(children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: (currentUser != null)
                    ? Image.network(currentUser.photoURL, width: 55)
                    : Container(
                        width: 70.0,
                        height: 70.0,
                        child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text('A'.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50))))),
            Text(currentUser.displayName)
          ]),
          decoration: BoxDecoration(color: Colors.blue)),
      ListTile(
          title: Text('Add Friends'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddFriendsRoute(currentUser: currentUser)));
          }),
      ListTile(
          title: Row(children: [
            Text('Pending Friends Requests'),
            numFriendRequests > 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Chip(
                        label: Text('${numFriendRequests}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.red))
                : Container(width: 0, height: 0)
          ]),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FriendRequestRoute(currentUser: currentUser)));
          }),
      ListTile(
          title: Text('Log out'),
          onTap: () {
            Navigator.pop(context);
            authService.signOut();
          })
    ]));
  }
}
