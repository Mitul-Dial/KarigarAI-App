class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.intentSummary = '',
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String intentSummary;

  Map<String, dynamic> toMap() => {
        'title': title,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'intentSummary': intentSummary,
      };

  factory ChatSession.fromMap(String id, Map<String, dynamic> data) {
    return ChatSession(
      id: id,
      title: data['title'] as String? ?? 'Chat',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      intentSummary: data['intentSummary'] as String? ?? '',
    );
  }
}
