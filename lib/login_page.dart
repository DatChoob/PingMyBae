import 'package:flutter/material.dart';
import 'package:pingmybae/google_signin_button.dart';
import 'package:pingmybae/util/authentication.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0, title: Text('Ping My Bae')),
        body: SafeArea(
            child: Container(
                padding: EdgeInsets.all(16.0),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Hero(
                      tag: 'loginHero',
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 70),
                          child: Image.asset(
                              "assets/images/main_logo_transparent.png",
                              height: 250.0)),
                    ),
                    GoogleSignInButton(onPressed: authService.googleSignIn)
                  ],
                ))));
  }
}
