import 'package:fcm_push/fcm_push.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/models/mood.dart';
import 'package:ping_friends/util/authentication.dart';
import 'package:ping_friends/util/firestore_util.dart';
import 'package:vector_math/vector_math.dart' show radians;
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' show Vector3;

final String serverKey =
    "AAAAuZeUo-s:APA91bHtlAXklqXnuCnPlcu_F01KJa38jtytOHODZuBlf56Z7B6upzbrYZaGx_hBJeKxMgsNuWfa3-X7GGyeUkMpLn6Yyy-729Y43R_hTI0FCjI5ahhenOn9vCbadUSQOdIMl0ek17my";

// Got this code from https://fireship.io/lessons/flutter-radial-menu-staggered-animations/
// Credit to Jeff Delaney
class RadialMenu extends StatefulWidget {
  final FirestoreUser person;
  RadialMenu({Key key, this.person}) : super(key: key);

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(controller: controller, person: widget.person);
  }
}

// The Animation
class RadialAnimation extends StatelessWidget {
  final AnimationController controller;
  Animation<double> scale;
  Animation<double> translation;
  final FirestoreUser person;
  RadialAnimation({Key key, this.controller, this.person}) {
    scale = Tween<double>(
      begin: 1.5,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticInOut),
    );
    translation = Tween<double>(
      begin: 0.0,
      end: 100.0,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutQuint),
    );
  }

  build(context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, builder) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _buildButton(0,
                  color: Colors.red,
                  icon: FontAwesomeIcons.angry,
                  mood: Mood.ANGRY),
              _buildButton(45,
                  color: Colors.teal,
                  icon: FontAwesomeIcons.smileBeam,
                  mood: Mood.HAPPY),
              _buildButton(90,
                  color: Colors.pinkAccent,
                  icon: FontAwesomeIcons.sadTear,
                  mood: Mood.SAD),
              _buildButton(135,
                  color: Colors.blue,
                  icon: FontAwesomeIcons.pizzaSlice,
                  mood: Mood.HANGRY),
              _buildButton(180,
                  color: Colors.deepOrange,
                  icon: FontAwesomeIcons.surprise,
                  mood: Mood.SURPRISED),
              _buildButton(225,
                  color: Colors.indigo,
                  icon: FontAwesomeIcons.tired,
                  mood: Mood.TIRED),
              _buildButton(270,
                  color: Colors.black,
                  icon: FontAwesomeIcons.userSecret,
                  mood: Mood.ALONE_TIME),
              _buildButton(315,
                  color: Colors.amber,
                  icon: FontAwesomeIcons.child,
                  mood: Mood.ATTENTION),
              Transform.scale(
                // subtract the beginning value to run the opposite animation
                scale: scale.value - 1.5,
                child: FloatingActionButton(
                    heroTag: "close",
                    child: Icon(FontAwesomeIcons.timesCircle),
                    onPressed: _close,
                    backgroundColor: Colors.red),
              ),
              Transform.scale(
                scale: scale.value,
                child: FloatingActionButton(
                    heroTag: "open",
                    child: Icon(FontAwesomeIcons.solidDotCircle),
                    onPressed: _open),
              )
            ],
          );
        });
  }

  _buildButton(double angle, {Color color, IconData icon, Mood mood}) {
    final double rad = radians(angle);
    return Transform(
      transform: Matrix4.translation(Vector3(
          (translation.value) * cos(rad), (translation.value) * sin(rad), 0)),
      child: Container(
        // constraints: BoxConstraints.tight(Size.square(500)),
        alignment: Alignment.center,
        // decoration:
        //     BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Tooltip(
          message: mood.tooltip,
          child: FloatingActionButton(
              heroTag: "icon.${icon.hashCode}",
              child: Icon(icon),
              backgroundColor: color,
              onPressed: () => sendNotification(mood),
              elevation: 0),
        ),
      ),
    );
  }

  _open() {
    controller.forward();
  }

  _close() {
    controller.reverse();
  }

  void sendNotification(Mood mood) async {
    final FCM fcm = FCM(serverKey);
    FirebaseUser currentUser = await authService.user.first.then((a) => a);
    final Message fcmMessage = Message()
      ..to = person.fcmToken
      ..title = currentUser.displayName
      ..body = "${currentUser.displayName} ${mood.message}";

    fcmMessage.data.add(Tuple2("type", mood.type));
    fcmMessage.data.add(Tuple2("fromUser", currentUser.uid));

    await fcm.send(fcmMessage);

    // tell firebase that we send a notification
    firestoreUtil.sentNotification(currentUser, person, mood);
    //
  }
}
