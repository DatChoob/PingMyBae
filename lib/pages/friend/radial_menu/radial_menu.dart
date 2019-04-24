import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:vector_math/vector_math.dart' show radians;
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' show Vector3;

final String serverKey =
    "AAAAuZeUo-s:APA91bHtlAXklqXnuCnPlcu_F01KJa38jtytOHODZuBlf56Z7B6upzbrYZaGx_hBJeKxMgsNuWfa3-X7GGyeUkMpLn6Yyy-729Y43R_hTI0FCjI5ahhenOn9vCbadUSQOdIMl0ek17my";

// Got this code from https://fireship.io/lessons/flutter-radial-menu-staggered-animations/
// Credit to Jeff Delaney
class RadialMenu extends StatefulWidget {
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  final List<Widget> buttons;
  RadialMenu({Key key, this.currentUser, this.friend, this.buttons})
      : super(key: key);

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
    return RadialAnimation(
        key: widget.key,
        controller: controller,
        currentUser: widget.currentUser,
        friend: widget.friend,
        buttons: widget.buttons);
  }
}

// The Animation
class RadialAnimation extends StatelessWidget {
  final AnimationController controller;
  Animation<double> scale;
  Animation<double> translation;
  final FirestoreUser friend;
  final FirestoreUser currentUser;
  final List<Widget> buttons;
  Key key;
  RadialAnimation(
      {this.key,
      this.controller,
      this.currentUser,
      this.friend,
      this.buttons}) {
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
            children: _buildButtons()
              ..add(Transform.scale(
                // subtract the beginning value to run the opposite animation
                scale: scale.value - 1.5,
                child: FloatingActionButton(
                    heroTag: "close$key",
                    child: Icon(FontAwesomeIcons.timesCircle),
                    onPressed: _close),
              ))
              ..add(Transform.scale(
                scale: scale.value,
                child: FloatingActionButton(
                    heroTag: "open$key",
                    child: Icon(FontAwesomeIcons.solidDotCircle),
                    onPressed: _open),
              )),
          );
        });
  }

  List<Widget> _buildButtons() {
    List<Widget> translatedButtons = [];
    for (var i = 0; i < buttons.length; i++) {
      Widget button = buttons[i];
      final double rad = radians(360 / buttons.length * i);
      translatedButtons.add(Transform(
          transform: Matrix4.translation(Vector3((translation.value) * cos(rad),
              (translation.value) * sin(rad), 0)),
          child: Container(
              // constraints: BoxConstraints.tight(Size.square(500)),
              alignment: Alignment.center,
              // decoration:
              //     BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: button)));
    }
    return translatedButtons;
  }

  _open() {
    controller.forward();
  }

  _close() {
    controller.reverse();
  }
}
