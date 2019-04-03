import 'package:fcm_push/fcm_push.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_friends/util/authentication.dart';
import 'package:ping_friends/util/firestore_util.dart';

import 'dart:math';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final String serverKey =
    "AAAAuZeUo-s:APA91bHtlAXklqXnuCnPlcu_F01KJa38jtytOHODZuBlf56Z7B6upzbrYZaGx_hBJeKxMgsNuWfa3-X7GGyeUkMpLn6Yyy-729Y43R_hTI0FCjI5ahhenOn9vCbadUSQOdIMl0ek17my";

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
            child: Hero(
                tag: "hero.${widget.person.uid}",
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(widget.person.photoURL)))),
        Expanded(child: Center(child: RadialMenu()))
      ]),
    );
  }

  void sendNotification(FirestoreUser user) async {
    final FCM fcm = FCM(serverKey);
    FirebaseUser currentUser = await authService.user.first.then((a) => a);
    final Message fcmMessage = Message()
      ..to = user.fcmToken
      ..title = user.displayName
      ..body = "${currentUser.displayName}  is pinging you";

    fcmMessage.data.add(Tuple2("type", "standard"));
    final String messageID = await fcm.send(fcmMessage);
  }
}

class RadialMenu extends StatefulWidget {
  RadialMenu({Key key}) : super(key: key);

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
        AnimationController(duration: Duration(milliseconds: 900), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(controller: controller);
  }
}

// The Animation
class RadialAnimation extends StatelessWidget {
  final AnimationController controller;
  Animation<double> scale;
  Animation<double> translation;

  RadialAnimation({Key key, this.controller}) {
    scale = Tween<double>(
      begin: 1.5,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
    );
    translation = Tween<double>(
      begin: 0.0,
      end: 100.0,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );
  }

  build(context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, builder) {
          return Stack(alignment: Alignment.center, children: [
            _buildButton(0,
                color: Colors.red,
                icon: FontAwesomeIcons.angry,
                message: "Is Feeling Angry",
                tooltip: "Angry"),
            _buildButton(45,
                color: Colors.green, icon: FontAwesomeIcons.sprayCan),
            _buildButton(90, color: Colors.orange, icon: FontAwesomeIcons.fire),
            _buildButton(135,
                color: Colors.blue, icon: FontAwesomeIcons.kiwiBird),
            _buildButton(180, color: Colors.black, icon: FontAwesomeIcons.cat),
            _buildButton(225, color: Colors.indigo, icon: FontAwesomeIcons.paw),
            _buildButton(270, color: Colors.pink, icon: FontAwesomeIcons.bong),
            _buildButton(315,
                color: Colors.yellow, icon: FontAwesomeIcons.bolt),
            Transform.scale(
              scale: scale.value -
                  1.5, // subtract the beginning value to run the opposite animation
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
                    onPressed: _open))
          ]);
        });
  }

  _buildButton(double angle,
      {Color color, IconData icon, String message, String tooltip}) {
    final double rad = radians(angle);

    return Transform(
        transformHitTests: true,
        transform: Matrix4.identity()
          ..translate(
              (translation.value) * cos(rad), (translation.value) * sin(rad)),
        child: FloatingActionButton(
            heroTag: "icon.${icon.hashCode}",
            child: Icon(icon),
            backgroundColor: color,
            onPressed: () => print("Pressed Button"),
            elevation: 0));
  }

  _open() {
    controller.forward();
  }

  _close() {
    controller.reverse();
  }
}
