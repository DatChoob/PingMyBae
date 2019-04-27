import 'package:fcm_push/fcm_push.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/mood_reaction.dart';
import 'package:ping_friends/pages/friend/radial_menu/radial_menu.dart';
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
        buttons: buildReactionButtons(context));
  }

  List<Widget> buildReactionButtons(BuildContext context) {
    return [
      _buildButton(
          color: Colors.green,
          icon: FontAwesomeIcons.handPaper,
          reaction: MoodReaction.WAVE,
          context: context),
      _buildButton(
          color: Colors.red,
          icon: Icons.thumb_down,
          reaction: MoodReaction.THUMBS_DOWN,
          context: context),
      _buildButton(
          color: Colors.deepOrange,
          icon: Icons.fastfood,
          reaction: MoodReaction.LETS_EAT,
          context: context),
      _buildButton(
          color: Colors.purple,
          icon: Icons.thumb_up,
          reaction: MoodReaction.THUMBS_UP,
          context: context),
    ];
  }

  _buildButton(
      {Color color,
      IconData icon,
      MoodReaction reaction,
      BuildContext context}) {
    return Tooltip(
      message: reaction.tooltip,
      child: FloatingActionButton(
          heroTag: "icon.${icon.hashCode}",
          child: Icon(icon),
          backgroundColor: color,
          onPressed: () => sendReactionNotification(reaction, context)),
    );
  }

  void sendReactionNotification(
      MoodReaction reaction, BuildContext context) async {
    final FCM fcm = FCM(DotEnv().env['FIREBASE_FCM_SERVER_KEY']);
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
    openSnackBar(reaction, context);
  }

  void openSnackBar(MoodReaction reaction, BuildContext context) {
    print("Das");
    final snackBar = SnackBar(
        duration: Duration(milliseconds: 100),
        content:
            Text('You pinged ${friend.displayName} with ${reaction.tooltip}'));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
