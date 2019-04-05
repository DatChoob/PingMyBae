import 'package:ping_friends/models/moods.dart';

class NotificationStats {
  int alone;
  int surprised;
  int sad;
  int happy;
  int angry;
  int hangry;
  int attention;
  int tired;
  NotificationStats(
      {this.alone,
      this.surprised,
      this.sad,
      this.happy,
      this.angry,
      this.attention,
      this.hangry,
      this.tired});

  static NotificationStats fromFirebase(Map<String, dynamic> data) {
    if (data == null) return empty();
    return NotificationStats(
        alone: data['${Moods.ALONE_TIME.type}'] ?? 0,
        surprised: data['${Moods.SURPRISED.type}'] ?? 0,
        attention: data['${Moods.ATTENTION.type}'] ?? 0,
        hangry: data['${Moods.HANGRY.type}'] ?? 0,
        tired: data['${Moods.TIRED.type}'] ?? 0,
        sad: data['${Moods.SAD.type}'] ?? 0,
        happy: data['${Moods.HAPPY.type}'] ?? 0,
        angry: data['${Moods.ANGRY.type}'] ?? 0);
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
        angry: 0);
  }
}
