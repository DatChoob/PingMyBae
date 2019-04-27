import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ping_friends/login_page.dart';
import 'package:ping_friends/models/firestore_user.dart';
import 'package:ping_friends/pages/home_page.dart';
import 'package:ping_friends/util/authentication.dart';
import 'package:ping_friends/util/firestore_util.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.white),
      home: RootPage(),
    );
  }
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_LOGGED_IN;

  FirestoreUser currentUser;

  @override
  void initState() {
    super.initState();
    authService.currentLoggedInUser.listen((FirestoreUser user) {
      if (user != null) {
        setState(() {
          currentUser = user;
          authStatus = AuthStatus.LOGGED_IN;
        });

        firestoreUtil
            .getCurrentRelationsSnapshot(currentUser.uid)
            .map((DocumentSnapshot snapshot) =>
                snapshot.exists ? snapshot.data : Map<String, dynamic>())
            .listen((relationsMap) =>
                setState(() => currentUser.currentRelations = relationsMap));
      } else {
        setState(() => authStatus = AuthStatus.NOT_LOGGED_IN);
      }
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
        body: SafeArea(
      child: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LoginPage();
        break;
      case AuthStatus.LOGGED_IN:
        if (currentUser != null && currentUser.currentRelations != null) {
          return HomePage(currentUser: currentUser);
        } else
          return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
