class Mood {
  final String _message;
  final String _tooltip;
  final String _type;

  const Mood._internal(this._message, this._tooltip, this._type);
  get message => _message;
  get tooltip => _tooltip;
  get type => _type;

  static const values = [
    ALONE_TIME,
    ATTENTION,
    TIRED,
    SURPRISED,
    HAPPY,
    SAD,
    HANGRY,
    ANGRY
  ];
  static const ALONE_TIME =
      const Mood._internal('wants privacy', 'Wants to be alone', "alone_time");
  static const ATTENTION =
      const Mood._internal('wants attention', 'Attention', 'attention');
  static const TIRED = const Mood._internal('is tired', 'Tired', 'tired');
  static const SURPRISED =
      const Mood._internal('is surprised', 'Surprised', 'surprised');
  static const HAPPY = const Mood._internal('is happy', 'Happy', 'happy');
  static const SAD = const Mood._internal('is sad', 'Sad', 'sad');
  static const HANGRY = const Mood._internal('is hangry', 'Hangry', 'hangry');
  static const ANGRY = const Mood._internal('is angry', 'Angry', 'angry');

  static Mood fromString(data) {
    if (data == null) return null;
    for (Mood mood in values) {
      if (mood.type == data) {
        return mood;
      }
    }
  }
}
