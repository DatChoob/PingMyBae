import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ping_friends/models/mood_reaction.dart';
import 'package:ping_friends/models/notification_stats.dart';

class FriendReactionStats extends StatelessWidget {
  final NotificationStats stats;
  const FriendReactionStats({Key key, this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
        Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(children: <Widget>[
            Text("Thumbs Up"),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                child: Icon(Icons.thumb_up,
                    color:
                        _highlightCurrentMood(stats, MoodReaction.THUMBS_UP))),
            Text('${stats.reactionThumbsUp}')
          ]),
          Column(
            children: <Widget>[
              Text("ThumbsDown"),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                  child: Icon(Icons.thumb_down,
                      color: _highlightCurrentMood(
                          stats, MoodReaction.THUMBS_DOWN))),
              Text('${stats.reactionThumbsDown}')
            ],
          ),
          Column(
            children: <Widget>[
              Text("Wave"),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                  child: Icon(FontAwesomeIcons.handPaper,
                      color: _highlightCurrentMood(stats, MoodReaction.WAVE))),
              Text('${stats.reactionWave}')
            ],
          ),
          Column(
            children: <Widget>[
              Text("Let's Eat"),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                  child: Icon(Icons.fastfood,
                      color:
                          _highlightCurrentMood(stats, MoodReaction.LETS_EAT))),
              Text('${stats.reactionLetsEat}')
            ],
          )
        ],
      ),
    ]);
  }

  _highlightCurrentMood(NotificationStats stats, MoodReaction reactionToCheck) {
    if (reactionToCheck == null) return null;
    if (stats.currentReaction?.type == reactionToCheck.type) {
      return Colors.pink;
    }
  }
}
