import 'package:flutter/material.dart';
import 'package:ping_friends/google_signin_button.dart';
import 'package:ping_friends/util/authentication.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Ping My Friends Login Page')),
        body: Container(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Hero(
                  tag: 'loginHero',
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 70.0),
                      child: FlutterLogo(size: 200)),
                ),
                GoogleSignInButton(onPressed: authService.googleSignIn)
              ],
            )));
  }
}
