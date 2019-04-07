import 'package:flutter/material.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/util/firestore_util.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FriendRequestRoute extends StatefulWidget {
  final FirestoreUser currentUser;

  FriendRequestRoute({Key key, this.currentUser}) : super(key: key);

  _FriendRequestRouteState createState() => _FriendRequestRouteState();
}

class _FriendRequestRouteState extends State<FriendRequestRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Friend Requests")),
        body: Container(child: _getFriendRequestList()));
  }

  _getFriendRequestList() {
    List<Future<FirestoreUser>> futureFriendRequests =
        widget.currentUser.getFriendRequests();
    return futureFriendRequests.isEmpty
        ? Center(child: Text("You have no friend requests"))
        : PersonCardList(
            futurePersons: futureFriendRequests,
            currentUser: widget.currentUser);
  }
}

class PersonCardList extends StatefulWidget {
  final List<Future<FirestoreUser>> futurePersons;
  final FirestoreUser currentUser;
  PersonCardList({Key key, this.futurePersons, this.currentUser})
      : super(key: key);

  @override
  _PersonCardListState createState() => _PersonCardListState();
}

class _PersonCardListState extends State<PersonCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.futurePersons.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
              future: widget.futurePersons[index],
              builder: (BuildContext context,
                  AsyncSnapshot<FirestoreUser> snapshot) {
                return snapshot.hasData
                    ? _personRowCard(snapshot.data, index)
                    : Center(child: CircularProgressIndicator());
              });
        });
  }

  _personRowCard(FirestoreUser friend, int index) {
    return Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      slideToDismissDelegate:
          new SlideToDismissDrawerDelegate(onDismissed: (actionType) {
        if (actionType == SlideActionType.primary) {
          _acceptFriendRequest(widget.currentUser.uid, friend.uid);
          _removeFriendFromList(index);
        } else {
          _rejectFriendRequest(widget.currentUser.uid, friend.uid);
          _removeFriendFromList(index);
        }
      }),
      key: ValueKey(friend.uid),
      child: ListTile(
          key: Key(friend.uid),
          leading: Hero(
            tag: "hero.${friend.uid}",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(friend.photoURL, width: 55),
            ),
          ),
          title: Text(friend.displayName),
          onTap: () async {
            bool acceptUserAsFriend = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text("Adding a friend"),
                      content: Text(
                          "Would you like to accept a friend request from ${friend.displayName}?"),
                      actions: <Widget>[
                        FlatButton(
                            child: Text("Accept"),
                            onPressed: () => Navigator.of(context).pop(true)),
                        FlatButton(
                            child: Text("Reject"),
                            onPressed: () => Navigator.of(context).pop(false))
                      ]);
                });
            if (acceptUserAsFriend == true) {
              _acceptFriendRequest(widget.currentUser.uid, friend.uid);
              _removeFriendFromList(index);
            } else if (acceptUserAsFriend == false) {
              _rejectFriendRequest(widget.currentUser.uid, friend.uid);
              _removeFriendFromList(index);
            }
          }),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Accept',
          color: Colors.green,
          icon: Icons.person,
        )
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Reject',
          color: Colors.red,
          icon: Icons.archive,
        ),
      ],
    );
  }

  void _acceptFriendRequest(String currentUserID, String friendUserID) {
    firestoreUtil.acceptFriendRequest(currentUserID, friendUserID);
  }

  void _rejectFriendRequest(String currentUserID, String friendUserID) {
    firestoreUtil.rejectFriendRequest(currentUserID, friendUserID);
  }

  void _removeFriendFromList(int index) {
    setState(() {
      widget.futurePersons.removeAt(index);
    });
  }
}
