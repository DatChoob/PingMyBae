import 'dart:io' show Platform;

class NotifactionFromMessage {
  final String notificationType;
  final String fromUserID;
  NotifactionFromMessage({this.notificationType, this.fromUserID});
  factory NotifactionFromMessage.fromNotification(
      Map<String, dynamic> message) {
    if (!Platform.isAndroid) {
      message = message['data'];
    }
    return NotifactionFromMessage(
        fromUserID: message['data']['fromUser'],
        notificationType: message['data']['type']);
  }
  get isMoodType => notificationType == 'mood';
  get isFriendRequestType => notificationType == 'friend_request';
}
