import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../theme/app_colors.dart';
import '../screens/direct_chat_screen.dart';

/// WhatsApp-style chat list for the Provider.
/// Shows customer chat cards from accepted requests only.
class ProviderChatListPanel extends StatelessWidget {
  const ProviderChatListPanel({
    super.key,
    required this.requests,
    required this.providerName,
  });

  final List<ServiceRequest> requests;
  final String providerName;

  /// Only requests that have been accepted by this provider.
  List<ServiceRequest> get _chatRequests {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final eligible = requests
        .where((r) =>
            r.providerUid == uid &&
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

    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 48, color: kTextMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text(
              'No customer chats yet',
              style: TextStyle(color: kTextMuted, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Accept a request to start chatting',
              style: TextStyle(color: kTextMuted, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: chats.length,
      itemBuilder: (_, i) => _CustomerChatTile(
        request: chats[i],
        providerName: providerName,
      ),
    );
  }
}

/// A single customer chat tile in the provider's chat list.
class _CustomerChatTile extends StatelessWidget {
  const _CustomerChatTile({
    required this.request,
    required this.providerName,
  });

  final ServiceRequest request;
  final String providerName;

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
                currentUserName: providerName,
                otherUserName: request.customerName ?? 'Customer',
                serviceName: request.service,
                isProvider: true,
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
                      ? kBlue.withValues(alpha: 0.10)
                      : kSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isActive ? kBlue : kBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    (request.customerName ?? 'C')[0].toUpperCase(),
                    style: TextStyle(
                      color: _isActive ? kBlue : kTextMuted,
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
                            request.customerName ?? 'Customer',
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
