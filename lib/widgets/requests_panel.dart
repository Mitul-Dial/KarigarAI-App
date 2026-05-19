import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../screens/direct_chat_screen.dart';
import '../theme/app_colors.dart';

class RequestsPanel extends StatelessWidget {
  const RequestsPanel({
    super.key,
    required this.requests,
    required this.isProvider,
    this.currentUserName = '',
    this.onVerifyComplete,
    this.onRate,
    this.onAccept,
    this.onDecline,
    this.onMove,
    this.onArrived,
    this.onComplete,
  });

  final List<ServiceRequest> requests;
  final bool isProvider;
  final String currentUserName;
  final void Function(ServiceRequest req)? onVerifyComplete;
  final void Function(ServiceRequest req, int stars, String feedback)? onRate;
  final void Function(ServiceRequest req)? onAccept;
  final void Function(ServiceRequest req)? onDecline;
  final void Function(ServiceRequest req)? onMove;
  final void Function(ServiceRequest req)? onArrived;
  final void Function(ServiceRequest req)? onComplete;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: kTextMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              isProvider ? 'No requests yet' : 'No service requests yet',
              style: TextStyle(color: kTextMuted, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              isProvider
                  ? 'Stay online to receive jobs'
                  : 'Book a provider from Assistant chat',
              style: TextStyle(color: kTextMuted.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) => _RequestCard(
        request: requests[index],
        isProvider: isProvider,
        currentUserName: currentUserName,
        onVerifyComplete: onVerifyComplete,
        onRate: onRate,
        onAccept: onAccept,
        onDecline: onDecline,
        onMove: onMove,
        onArrived: onArrived,
        onComplete: onComplete,
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({
    required this.request,
    required this.isProvider,
    this.currentUserName = '',
    this.onVerifyComplete,
    this.onRate,
    this.onAccept,
    this.onDecline,
    this.onMove,
    this.onArrived,
    this.onComplete,
  });

  final ServiceRequest request;
  final bool isProvider;
  final String currentUserName;
  final void Function(ServiceRequest req)? onVerifyComplete;
  final void Function(ServiceRequest req, int stars, String feedback)? onRate;
  final void Function(ServiceRequest req)? onAccept;
  final void Function(ServiceRequest req)? onDecline;
  final void Function(ServiceRequest req)? onMove;
  final void Function(ServiceRequest req)? onArrived;
  final void Function(ServiceRequest req)? onComplete;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  int _rating = 8;
  final _feedbackCtrl = TextEditingController();

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return kWarning;
      case 'ACCEPTED':
      case 'ON_THE_WAY':
      case 'ARRIVED':
        return kBlue;
      case 'COMPLETION_REQUESTED':
        return kBlueMid;
      case 'COMPLETED':
      case 'RATED':
        return kGoldenBeige;
      case 'DECLINED':
        return Colors.red.shade300;
      default:
        return kTextMuted;
    }
  }

  String _statusMessage(ServiceRequest r) {
    switch (r.status) {
      case 'PENDING':
        return isProvider
            ? 'New job request — accept or decline'
            : 'Waiting for provider to accept…';
      case 'ACCEPTED':
        return 'Provider accepted your request';
      case 'ON_THE_WAY':
        return 'Provider is on the way';
      case 'ARRIVED':
        return 'Provider has arrived';
      case 'COMPLETION_REQUESTED':
        return 'Provider marked job complete — please verify';
      case 'COMPLETED':
        return 'Job verified — please rate 1–10';
      case 'RATED':
        return isProvider
            ? 'Customer rated this job — see feedback below'
            : 'Feedback submitted — thank you!';
      case 'DECLINED':
        return 'Request was declined';
      default:
        return r.status;
    }
  }

  bool get isProvider => widget.isProvider;
  ServiceRequest get r => widget.request;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(r.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.id.length > 8 ? r.id.substring(0, 8) : r.id,
                  style: const TextStyle(fontSize: 10, color: kTextMuted, fontFamily: 'monospace')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  r.status.replaceAll('_', ' '),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(r.service, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kText)),
          if (r.providerName != null && !isProvider)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Provider: ${r.providerName}', style: const TextStyle(color: kBlue, fontSize: 13)),
            ),
          if (r.customerName != null && isProvider)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Customer: ${r.customerName}', style: const TextStyle(color: kText, fontSize: 13)),
            ),
          if (isProvider && r.rating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: kWarning, size: 18),
                Text(' ${r.rating}/10', style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
              ],
            ),
          ],
          if (isProvider && r.feedback != null && r.feedback!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer feedback',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: kText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.feedback!.trim(),
                    style: const TextStyle(fontSize: 13, color: kText, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          _row(Icons.schedule, r.time),
          _row(Icons.location_on_outlined, r.location),
          if (r.price.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(r.price, style: const TextStyle(fontWeight: FontWeight.w700, color: kGoldenBeige)),
            ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusMessage(r),
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
          ),
          ..._actions(),
        ],
      ),
    );
  }

  List<Widget> _actions() {
    final w = <Widget>[];

    // Chat button for active requests (after acceptance)
    final _chatStatuses = {'ACCEPTED', 'ON_THE_WAY', 'ARRIVED', 'COMPLETION_REQUESTED'};
    if (_chatStatuses.contains(r.status) && r.providerUid != null) {
      final user = FirebaseAuth.instance.currentUser;
      final rowBtns = <Widget>[_chatBtn(context, user)];
      if (isProvider && r.status == 'ACCEPTED')
        rowBtns.add(_btn('Move', kBlue, () => widget.onMove?.call(r)));
      if (isProvider && r.status == 'ON_THE_WAY')
        rowBtns.add(_btn('Arrived', kGoldenBeige, () => widget.onArrived?.call(r)));
      if (isProvider && r.status == 'ARRIVED')
        rowBtns.add(_btn('Complete job', kBlue, () => widget.onComplete?.call(r)));
      if (!isProvider && r.status == 'COMPLETION_REQUESTED')
        rowBtns.add(_btn('Verify & complete', kGoldenBeige, () => widget.onVerifyComplete?.call(r)));
      w.add(_btnRow(rowBtns));
    } else if (isProvider && r.status == 'PENDING') {
      w.add(_btnRow([
        _btn('Accept', kGoldenBeige, () => widget.onAccept?.call(r)),
        _btn('Decline', kTextMuted, () => widget.onDecline?.call(r), outline: true),
      ]));
    }
    if (!isProvider && r.status == 'COMPLETED') {
      w.add(const SizedBox(height: 10));
      w.add(const Text('Rate 1–10', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)));
      w.add(Wrap(
        spacing: 2,
        children: List.generate(10, (i) {
          final s = i + 1;
          return IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => setState(() => _rating = s),
            icon: Icon(
              s <= _rating ? Icons.star : Icons.star_border,
              color: kWarning,
              size: 22,
            ),
          );
        }),
      ));
      w.add(TextField(
        controller: _feedbackCtrl,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Feedback (optional)',
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ));
      w.add(_btn('Submit feedback', kWarning, () {
        widget.onRate?.call(r, _rating, _feedbackCtrl.text.trim());
      }));
    }
    return w;
  }

  Widget _btnRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: children.map((c) => Expanded(child: c)).toList()),
    );
  }

  Widget _chatBtn(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DirectChatScreen(
                  requestId: r.id,
                  currentUid: user?.uid ?? '',
                  currentUserName: widget.currentUserName.isNotEmpty
                      ? widget.currentUserName
                      : (isProvider
                          ? (r.providerName ?? 'Provider')
                          : (r.customerName ?? 'Customer')),
                  otherUserName: isProvider
                      ? (r.customerName ?? 'Customer')
                      : (r.providerName ?? 'Provider'),
                  serviceName: r.service,
                  isProvider: isProvider,
                ),
              ),
            );
          },
          icon: const Icon(Icons.chat_outlined, size: 16),
          label: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: isProvider ? kGoldenBeige : kBlue,
            foregroundColor: kWhite,
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback? onTap, {bool outline = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 4),
      child: SizedBox(
        width: double.infinity,
        child: outline
            ? OutlinedButton(onPressed: onTap, child: Text(label))
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: kWhite),
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kTextMuted),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: kTextMuted))),
        ],
      ),
    );
  }
}
