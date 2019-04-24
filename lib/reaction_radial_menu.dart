import 'package:fcm_push/fcm_push.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/mood_reaction.dart';
import 'package:ping_friends/radial_menu.dart';
import 'package:ping_friends/util/firestore_util.dart';

class ReactionRadialMenu extends StatelessWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  const ReactionRadialMenu({Key key, this.friend, this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadialMenu(
        key: Key('reaction'),
        friend: friend,
        currentUser: currentUser,
        buttons: buildReactionButtons());
  }

  List<Widget> buildReactionButtons() {
    return [
      _buildButton(
          color: Colors.green,
          icon: FontAwesomeIcons.handPaper,
          reaction: MoodReaction.WAVE),
      // _buildButton(
      //     color: Colors.pinkAccent,
      //     icon: FontAwesomeIcons.sadTear,
      //     reaction: MoodReaction.SOUNDS_GOOD),

      _buildButton(
          color: Colors.deepOrange,
          icon: Icons.thumb_down,
          reaction: MoodReaction.THUMBS_DOWN),

      _buildButton(
          color: Colors.indigo,
          icon: Icons.fastfood,
          reaction: MoodReaction.LETS_EAT),
      _buildButton(
          color: Colors.blue,
          icon: Icons.thumb_up,
          reaction: MoodReaction.THUMBS_UP),
    ];
  }

  _buildButton({Color color, IconData icon, MoodReaction reaction}) {
    return Tooltip(
      message: reaction.tooltip,
      child: FloatingActionButton(
          heroTag: "icon.${icon.hashCode}",
          child: Icon(icon),
          backgroundColor: color,
          onPressed: () => sendReactionNotification(reaction)),
    );
  }

  void sendReactionNotification(MoodReaction reaction) async {
    final FCM fcm = FCM(serverKey);
    final Message fcmMessage = Message()
      ..to = friend.fcmToken
      ..title = currentUser.displayName
      ..body = "${currentUser.displayName} ${reaction.message}";

    fcmMessage.data.add(Tuple2("type", 'mood'));
    fcmMessage.data.add(Tuple2("fromUser", currentUser.uid));
    fcmMessage.data.add(Tuple2("click_action", "FLUTTER_NOTIFICATION_CLICK"));

    await fcm.send(fcmMessage);

    // tell firebase that we send a notification
    firestoreUtil.sentReactionNotification(currentUser, friend, reaction);
    //
  }
}
