class Moods {
  final String _message;
  final String _tooltip;
  final String _type;

  const Moods._internal(this._message, this._tooltip, this._type);
  get message => _message;
  get tooltip => _tooltip;
  get type => _type;

  static const values = [
    ALONE_TIME,
    ATTENTION,
    TIRED,
    HAPPY,
    SAD,
    HANGRY,
    ANGRY
  ];
  static const ALONE_TIME =
      const Moods._internal('wants privacy', 'Wants to be alone', "alone_time");
  static const ATTENTION =
      const Moods._internal('wants attention', 'Attention', 'attention');
  static const TIRED = const Moods._internal('is tired', 'Tired', 'tired');
  static const SURPRISED =
      const Moods._internal('is surprised', 'Surprised', 'surprised');
  static const HAPPY = const Moods._internal('is happy', 'Happy', 'happy');
  static const SAD = const Moods._internal('is sad', 'Sad', 'sad');
  static const HANGRY = const Moods._internal('is hangry', 'Hangry', 'hangry');
  static const ANGRY = const Moods._internal('is angry', 'Angry', 'angry');

  static Moods fromString(data) {
    if (data == null) return null;
    for (Moods mood in values) {
      if (mood.type == data) {
        return mood;
      }
    }
  }
}
