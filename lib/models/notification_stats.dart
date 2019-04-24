import 'package:ping_friends/models/mood.dart';
import 'package:ping_friends/models/mood_reaction.dart';

class NotificationStats {
  int moodAlone;
  int moodSurprised;
  int moodSad;
  int moodHappy;
  int moodAngry;
  int moodHangry;
  int moodAttention;
  int moodTired;
  Mood currentMood;

  int reactionThumbsUp;
  int reactionThumbsDown;
  int reactionLetsEat;
  int reactionWave;
  MoodReaction currentReaction;

  NotificationStats(
      {this.moodAlone,
      this.moodSurprised,
      this.moodSad,
      this.moodHappy,
      this.moodAngry,
      this.moodAttention,
      this.moodHangry,
      this.moodTired,
      this.currentMood,
      this.reactionThumbsUp,
      this.reactionThumbsDown,
      this.reactionLetsEat,
      this.reactionWave,
      this.currentReaction});

  static NotificationStats fromFirebase(Map<String, dynamic> data) {
    if (data == null) return empty();
    return NotificationStats(
        moodAlone: data['${Mood.ALONE_TIME.type}'] ?? 0,
        moodSurprised: data['${Mood.SURPRISED.type}'] ?? 0,
        moodAttention: data['${Mood.ATTENTION.type}'] ?? 0,
        moodHangry: data['${Mood.HANGRY.type}'] ?? 0,
        moodTired: data['${Mood.TIRED.type}'] ?? 0,
        moodSad: data['${Mood.SAD.type}'] ?? 0,
        moodHappy: data['${Mood.HAPPY.type}'] ?? 0,
        moodAngry: data['${Mood.ANGRY.type}'] ?? 0,
        currentMood: Mood.fromString(data['currentMood']),
        reactionThumbsUp: data['${MoodReaction.THUMBS_UP.type}'] ?? 0,
        reactionThumbsDown: data['${MoodReaction.THUMBS_DOWN.type}'] ?? 0,
        reactionLetsEat: data['${MoodReaction.LETS_EAT.type}'] ?? 0,
        reactionWave: data['${MoodReaction.WAVE.type}'] ?? 0,
        currentReaction: MoodReaction.fromString(data['currentReaction']));
  }

  static NotificationStats empty() {
    return NotificationStats(
        moodAlone: 0,
        moodSurprised: 0,
        moodAttention: 0,
        moodHangry: 0,
        moodTired: 0,
        moodSad: 0,
        moodHappy: 0,
        moodAngry: 0,
        currentMood: null,
        reactionThumbsUp: 0,
        reactionThumbsDown: 0,
        reactionLetsEat: 0,
        reactionWave: 0,
        currentReaction: null);
  }
}
