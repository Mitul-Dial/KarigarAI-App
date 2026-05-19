import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../theme/app_colors.dart';
import '../screens/direct_chat_screen.dart';

/// WhatsApp-style chat list for the Customer.
/// Shows the AI Assistant card pinned at the top, followed by
/// all provider chats from accepted requests (current and past).
class CustomerChatListPanel extends StatelessWidget {
  const CustomerChatListPanel({
    super.key,
    required this.requests,
    required this.onAssistantTap,
    required this.customerName,
  });

  final List<ServiceRequest> requests;
  final VoidCallback onAssistantTap;
  final String customerName;

  /// Only requests that have been accepted (have a providerUid) are eligible
  /// for direct chat.
  List<ServiceRequest> get _chatRequests {
    final eligible = requests
        .where((r) =>
            r.providerUid != null &&
            r.providerUid!.isNotEmpty &&
            r.status != 'PENDING' &&
            r.status != 'DECLINED')
        .toList();
    eligible.sort((a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return eligible;
  }

  @override
  Widget build(BuildContext context) {
    final chats = _chatRequests;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        // ── Pinned Assistant card ──
        _AssistantChatTile(onTap: onAssistantTap),
        if (chats.isNotEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              'Provider Chats',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kTextMuted,
              ),
            ),
          ),
        ...chats.map((req) => _ProviderChatTile(
              request: req,
              customerName: customerName,
            )),
        if (chats.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 40, color: kTextMuted.withValues(alpha: 0.3)),
                  const SizedBox(height: 10),
                  const Text(
                    'No provider chats yet',
                    style: TextStyle(color: kTextMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Book a service to start chatting',
                    style: TextStyle(color: kTextMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The pinned AI Assistant tile at the top of the chat list.
class _AssistantChatTile extends StatelessWidget {
  const _AssistantChatTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBlue.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: kBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kBlue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Flaviotte',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Ustaad AI',
                          style: TextStyle(
                            fontFamily: 'Flaviotte',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: kText,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: kBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Har kaam ka ustaad — Ask me anything!',
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.push_pin, size: 14, color: kTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single provider chat tile in the chat list.
class _ProviderChatTile extends StatelessWidget {
  const _ProviderChatTile({
    required this.request,
    required this.customerName,
  });

  final ServiceRequest request;
  final String customerName;

  bool get _isActive =>
      request.status == 'ACCEPTED' ||
      request.status == 'ON_THE_WAY' ||
      request.status == 'ARRIVED' ||
      request.status == 'COMPLETION_REQUESTED';

  String get _subtitle {
    if (request.status == 'RATED' || request.status == 'COMPLETED') {
      return '${request.service} • Completed';
    }
    return '${request.service} • ${request.status.replaceAll('_', ' ')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DirectChatScreen(
                requestId: request.id,
                currentUid: user?.uid ?? '',
                currentUserName: customerName,
                otherUserName: request.providerName ?? 'Provider',
                serviceName: request.service,
                isProvider: false,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _isActive
                      ? kGoldenBeige.withValues(alpha: 0.15)
                      : kSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isActive ? kGoldenBeige : kBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    (request.providerName ?? 'P')[0].toUpperCase(),
                    style: TextStyle(
                      color: _isActive ? kGoldenBeige : kTextMuted,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.providerName ?? 'Provider',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: kText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isActive)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kSuccess,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: kTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
