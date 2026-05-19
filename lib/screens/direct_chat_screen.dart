import 'dart:async';
import 'package:flutter/material.dart';
import '../models/direct_message.dart';
import '../services/direct_chat_repository.dart';
import '../theme/app_colors.dart';

/// WhatsApp-style 1-on-1 chat screen between customer and provider.
class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({
    super.key,
    required this.requestId,
    required this.currentUid,
    required this.currentUserName,
    required this.otherUserName,
    required this.serviceName,
    required this.isProvider,
  });

  final String requestId;
  final String currentUid;
  final String currentUserName;
  final String otherUserName;
  final String serviceName;
  final bool isProvider;

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<DirectMessage> _messages = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = DirectChatRepository.instance
        .watchMessages(widget.requestId)
        .listen((msgs) {
      if (mounted) {
        setState(() => _messages = msgs);
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await DirectChatRepository.instance.sendMessage(
      requestId: widget.requestId,
      senderUid: widget.currentUid,
      senderName: widget.currentUserName,
      text: text,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: widget.isProvider
            ? kGoldenBeige.withValues(alpha: 0.12)
            : kBlue.withValues(alpha: 0.08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: kText,
              ),
            ),
            Text(
              widget.serviceName,
              style: const TextStyle(
                fontSize: 11,
                color: kTextMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
        leadingWidth: 40,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_outlined,
                            size: 48,
                            color: kTextMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'Say hello to ${widget.otherUserName}!',
                          style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your messages are private and secure',
                          style: TextStyle(
                            color: kTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg.senderUid == widget.currentUid;
                      final showDate = i == 0 ||
                          !_isSameDay(
                              _messages[i - 1].timestamp, msg.timestamp);

                      return Column(
                        children: [
                          if (showDate) _dateSeparator(msg.timestamp),
                          _chatBubble(msg, isMe),
                        ],
                      );
                    },
                  ),
          ),
          _inputArea(),
        ],
      ),
    );
  }

  Widget _dateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(date, now)) {
      label = 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label =
          '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: kTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _chatBubble(DirectMessage msg, bool isMe) {
    final time =
        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        decoration: BoxDecoration(
          color: isMe
              ? (widget.isProvider ? kGoldenBeige : kBlue)
              : kSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: (isMe ? kBlueDark : kBorder).withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isMe ? kWhite : kText,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? kWhite.withValues(alpha: 0.7)
                    : kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          8, 8, 8, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: kWhite,
        border: const Border(top: BorderSide(color: kBorder)),
        boxShadow: [
          BoxShadow(
            color: kBorder.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(color: kTextMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: widget.isProvider ? kGoldenBeige : kBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isProvider ? kGoldenBeige : kBlue)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: kWhite, size: 20),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }
}
