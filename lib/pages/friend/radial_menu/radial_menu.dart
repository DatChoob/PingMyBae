import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:vector_math/vector_math.dart' show radians;
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' show Vector3;

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
              ..add(
                Transform.scale(
                  // subtract the beginning value to run the opposite animation
                  scale: scale.value - 1.5,
                  child: GestureDetector(
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(),
                        child:
                            Center(child: CustomPaint(painter: ColorWheel()))),
                    onTap: _close,
                  ),
                ),
              )
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
          child: Container(alignment: Alignment.center, child: button)));
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

class ColorWheel extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromCircle(
      center: Offset.zero,
      radius: 30.0,
    );
    canvas.rotate(radians(180.0));

    // a fancy rainbow gradient
    final Gradient gradient = SweepGradient(
      colors: <Color>[
        Color(0xFFFF0000),
        Colors.orange,
        Color(0xFF70FF00),
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFF0000FF),
        Color(0xFF7F00FF),
        Color(0xFFFF00FF),
      ],
      // stops: [
      //   0.0,
      //   0.13,
      //   0.25,
      //   0.35,
      //   0.5,
      //   0.63,
      //   0.75,
      //   0.88,
      //   // 1.0,
      // ],
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawArc(rect, 0, 2 * pi, true, paint);
  }

  @override
  bool shouldRepaint(ColorWheel oldDelegate) {
    return true;
  }
}
