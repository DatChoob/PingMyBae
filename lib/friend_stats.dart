import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/mood.dart';
import 'package:ping_friends/models/notification_stats.dart';

class FriendStats extends StatelessWidget {
  final NotificationStats stats;
  const FriendStats({Key key, this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(children: <Widget>[
                Text("Happy"),
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                    child: Icon(FontAwesomeIcons.smileBeam,
                        color: _highlightCurrentMood(stats, Mood.HAPPY))),
                Text('${stats.happy}')
              ]),
              Column(
                children: <Widget>[
                  Text("Attention"),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                      child: Icon(FontAwesomeIcons.child,
                          color: _highlightCurrentMood(stats, Mood.ATTENTION))),
                  Text('${stats.attention}')
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Surprised"),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                      child: Icon(FontAwesomeIcons.surprise,
                          color: _highlightCurrentMood(stats, Mood.SURPRISED))),
                  Text('${stats.surprised}')
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Hangry"),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                      child: Icon(FontAwesomeIcons.pizzaSlice,
                          color: _highlightCurrentMood(stats, Mood.HANGRY))),
                  Text('${stats.hangry}')
                ],
              )
            ],
          ),
          SizedBox(width: 10, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(children: <Widget>[
                Text("Sad"),
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                    child: Icon(FontAwesomeIcons.sadTear,
                        color: _highlightCurrentMood(stats, Mood.SAD))),
                Text('${stats.sad}'),
              ]),
              Column(
                children: <Widget>[
                  Text("Angry"),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                      child: Icon(FontAwesomeIcons.angry,
                          color: _highlightCurrentMood(stats, Mood.ANGRY))),
                  Text('${stats.angry}'),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Alone Time"),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                      child: Icon(FontAwesomeIcons.userSecret,
                          color:
                              _highlightCurrentMood(stats, Mood.ALONE_TIME))),
                  Text('${stats.alone}'),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Tired"),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                      child: Icon(
                        FontAwesomeIcons.tired,
                        color: _highlightCurrentMood(stats, Mood.TIRED),
                      )),
                  Text('${stats.tired}'),
                ],
              )
            ],
          )
        ]);
  }

  _highlightCurrentMood(NotificationStats stats, Mood moodToCheck) {
    if (moodToCheck == null) return null;
    if (stats.currentMood?.type == moodToCheck.type) {
      return Colors.pink;
    }
  }
}
