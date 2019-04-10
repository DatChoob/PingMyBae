import 'dart:io' show Platform;

class NotifactionFromMessage {
  final String notificationType;
  final String fromUserID;
  NotifactionFromMessage({this.notificationType, this.fromUserID});
  factory NotifactionFromMessage.fromNotification(
      Map<dynamic, dynamic> message) {
    if (Platform.isAndroid) {
      message = message['data'];
    }
    return NotifactionFromMessage(
        fromUserID: message['fromUser'], notificationType: message['type']);
  }
  get isMoodType => notificationType == 'mood';
  get isFriendRequestType => notificationType == 'friend_request';
}
