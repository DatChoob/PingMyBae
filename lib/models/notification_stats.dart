import 'package:ping_friends/models/mood.dart';

class NotificationStats {
  int alone;
  int surprised;
  int sad;
  int happy;
  int angry;
  int hangry;
  int attention;
  int tired;
  Mood currentMood;
  NotificationStats(
      {this.alone,
      this.surprised,
      this.sad,
      this.happy,
      this.angry,
      this.attention,
      this.hangry,
      this.tired,
      this.currentMood});

  static NotificationStats fromFirebase(Map<String, dynamic> data) {
    if (data == null) return empty();
    return NotificationStats(
        alone: data['${Mood.ALONE_TIME.type}'] ?? 0,
        surprised: data['${Mood.SURPRISED.type}'] ?? 0,
        attention: data['${Mood.ATTENTION.type}'] ?? 0,
        hangry: data['${Mood.HANGRY.type}'] ?? 0,
        tired: data['${Mood.TIRED.type}'] ?? 0,
        sad: data['${Mood.SAD.type}'] ?? 0,
        happy: data['${Mood.HAPPY.type}'] ?? 0,
        angry: data['${Mood.ANGRY.type}'] ?? 0,
        currentMood: Mood.fromString(data['currentMood']));
  }

  static NotificationStats empty() {
    return NotificationStats(
        alone: 0,
        surprised: 0,
        attention: 0,
        hangry: 0,
        tired: 0,
        sad: 0,
        happy: 0,
        angry: 0,
        currentMood: null);
  }
}
