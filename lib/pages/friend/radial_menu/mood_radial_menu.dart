import 'dart:async';

import 'package:fcm_push/fcm_push.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/mood.dart';
import 'package:ping_friends/pages/friend/radial_menu/radial_menu.dart';
import 'package:ping_friends/util/firestore_util.dart';

class MoodRadialMenu extends StatefulWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  MoodRadialMenu({Key key, this.friend, this.currentUser}) : super(key: key);

  @override
  _MoodRadialMenuState createState() => _MoodRadialMenuState();
}

class _MoodRadialMenuState extends State<MoodRadialMenu> {
  bool waitTilTimerCompletes = false;

  @override
  Widget build(BuildContext context) {
    return RadialMenu(
        key: Key('mood'),
        friend: widget.friend,
        currentUser: widget.currentUser,
        buttons: buildMoodButtons(context));
  }

  List<Widget> buildMoodButtons(BuildContext context) {
    return [
      _buildButton(
          color: Color(0xFFFF0000),
          icon: FontAwesomeIcons.angry,
          mood: Mood.ANGRY,
          context: context),
      _buildButton(
          color: Colors.orange,
          icon: FontAwesomeIcons.smileBeam,
          mood: Mood.HAPPY,
          context: context),
      _buildButton(
          color: Color(0xFF70FF00),
          icon: FontAwesomeIcons.sadTear,
          mood: Mood.SAD,
          context: context),
      _buildButton(
          color: Color(0xFF00FF00),
          icon: FontAwesomeIcons.pizzaSlice,
          mood: Mood.HANGRY,
          context: context),
      _buildButton(
          color: Color(0xFF00FFFF),
          icon: FontAwesomeIcons.surprise,
          mood: Mood.SURPRISED,
          context: context),
      _buildButton(
          color: Color(0xFF0000FF),
          icon: FontAwesomeIcons.tired,
          mood: Mood.TIRED,
          context: context),
      _buildButton(
          color: Color(0xFF7F00FF),
          icon: FontAwesomeIcons.userSecret,
          mood: Mood.ALONE_TIME,
          context: context),
      _buildButton(
          color: Color(0xFFFF00FF),
          icon: FontAwesomeIcons.child,
          mood: Mood.ATTENTION,
          context: context)
    ];
  }

  _buildButton({Color color, IconData icon, Mood mood, BuildContext context}) {
    return Tooltip(
      message: mood.tooltip,
      child: FloatingActionButton(
          heroTag: "icon.${icon.hashCode}",
          child: Icon(icon),
          backgroundColor: color,
          onPressed: () => sendMoodNotification(mood, context)),
    );
  }

  void sendMoodNotification(Mood mood, BuildContext context) async {
    if (waitTilTimerCompletes) {
      // final snackBar = SnackBar(
      //     duration: Duration(milliseconds: 100),
      //     content: Text(
      //         "You've sent too many at one time. try again in a few seconds."));
      // Scaffold.of(context).showSnackBar(snackBar);
    } else {
      setState(() {
        waitTilTimerCompletes = true;
      });
      final FCM fcm = FCM(DotEnv().env['FIREBASE_FCM_SERVER_KEY']);
      final Message fcmMessage = Message()
        ..to = widget.friend.fcmToken
        ..title = widget.currentUser.displayName
        ..body = "${widget.currentUser.displayName} ${mood.message}";

      fcmMessage.data.add(Tuple2("type", 'mood'));
      fcmMessage.data.add(Tuple2("fromUser", widget.currentUser.uid));
      fcmMessage.data.add(Tuple2("click_action", "FLUTTER_NOTIFICATION_CLICK"));

      await fcm.send(fcmMessage);

      // tell firebase that we send a notification
      firestoreUtil.sentMoodNotification(
          widget.currentUser, widget.friend, mood);
      openSnackBar(mood, context);
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          waitTilTimerCompletes = false;
        });
      });
    }
  }

  void openSnackBar(Mood mood, BuildContext context) {
    final snackBar = SnackBar(
        duration: Duration(milliseconds: 100),
        content: Text(
            'You pinged ${widget.friend.displayName} with ${mood.tooltip}'));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
