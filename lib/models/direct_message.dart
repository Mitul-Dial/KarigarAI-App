/// A single message in a direct chat between customer and provider.
class DirectMessage {
  DirectMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String senderUid;
  final String senderName;
  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
        'senderUid': senderUid,
        'senderName': senderName,
        'text': text,
        'timestamp': timestamp,
      };

  factory DirectMessage.fromMap(String id, Map<String, dynamic> data) {
    return DirectMessage(
      id: id,
      senderUid: data['senderUid'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
