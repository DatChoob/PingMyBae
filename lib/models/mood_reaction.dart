class MoodReaction {
  final String _message;
  final String _tooltip;
  final String _type;

  const MoodReaction._internal(this._message, this._tooltip, this._type);
  get message => _message;
  get tooltip => _tooltip;
  get type => _type;

  static const values = [
    LETS_EAT,
    LIKE,
    THUMBS_UP,
    //  SAD_FACE,
    WAVE,
    COOL,
    SOUNDS_GOOD,
    THUMBS_DOWN
  ];

  static const LIKE =
      const MoodReaction._internal('sent a like', 'Like', "reaction_like");
  static const LETS_EAT = const MoodReaction._internal(
      "said let's eat", "Let's Eat", "reaction_lets_eat");
  static const THUMBS_UP = const MoodReaction._internal(
      'sent two thumbs up', 'Thumbs Up', 'reaction_thumbs_up');
  static const THUMBS_DOWN = const MoodReaction._internal(
      'sent  thumbs down', 'Thumbs Down', 'reaction_thumbs_down');
  static const WAVE =
      const MoodReaction._internal('sent a wave', 'Wave', 'reaction_wave');
  static const COOL =
      const MoodReaction._internal('said cool', 'Cool', 'reaction_cool');
  static const SOUNDS_GOOD = const MoodReaction._internal(
      'said sounds good', 'Sounds Good', 'reaction_sounds_good');

  static MoodReaction fromString(data) {
    if (data == null) return null;
    for (MoodReaction reaction in values) {
      if (reaction.type == data) {
        return reaction;
      }
    }
    return null;
  }
}
