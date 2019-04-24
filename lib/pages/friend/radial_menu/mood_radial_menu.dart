import 'package:fcm_push/fcm_push.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/mood.dart';
import 'package:ping_friends/pages/friend/radial_menu/radial_menu.dart';
import 'package:ping_friends/util/firestore_util.dart';

class MoodRadialMenu extends StatelessWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  const MoodRadialMenu({Key key, this.friend, this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadialMenu(
        key: Key('mood'),
        friend: friend,
        currentUser: currentUser,
        buttons: buildMoodButtons());
  }

  List<Widget> buildMoodButtons() {
    return [
      _buildButton(
          color: Colors.red, icon: FontAwesomeIcons.angry, mood: Mood.ANGRY),
      _buildButton(
          color: Colors.teal,
          icon: FontAwesomeIcons.smileBeam,
          mood: Mood.HAPPY),
      _buildButton(
          color: Colors.pinkAccent,
          icon: FontAwesomeIcons.sadTear,
          mood: Mood.SAD),
      _buildButton(
          color: Colors.blue,
          icon: FontAwesomeIcons.pizzaSlice,
          mood: Mood.HANGRY),
      _buildButton(
          color: Colors.deepOrange,
          icon: FontAwesomeIcons.surprise,
          mood: Mood.SURPRISED),
      _buildButton(
          color: Colors.indigo, icon: FontAwesomeIcons.tired, mood: Mood.TIRED),
      _buildButton(
          color: Colors.black,
          icon: FontAwesomeIcons.userSecret,
          mood: Mood.ALONE_TIME),
      _buildButton(
          color: Colors.amber,
          icon: FontAwesomeIcons.child,
          mood: Mood.ATTENTION)
    ];
  }

  _buildButton({Color color, IconData icon, Mood mood}) {
    return Tooltip(
      message: mood.tooltip,
      child: FloatingActionButton(
          heroTag: "icon.${icon.hashCode}",
          child: Icon(icon),
          backgroundColor: color,
          onPressed: () => sendMoodNotification(mood)),
    );
  }

  void sendMoodNotification(Mood mood) async {
    final FCM fcm = FCM(serverKey);
    final Message fcmMessage = Message()
      ..to = friend.fcmToken
      ..title = currentUser.displayName
      ..body = "${currentUser.displayName} ${mood.message}";

    fcmMessage.data.add(Tuple2("type", 'mood'));
    fcmMessage.data.add(Tuple2("fromUser", currentUser.uid));
    fcmMessage.data.add(Tuple2("click_action", "FLUTTER_NOTIFICATION_CLICK"));

    await fcm.send(fcmMessage);

    // tell firebase that we send a notification
    firestoreUtil.sentMoodNotification(currentUser, friend, mood);
    //
  }
}
