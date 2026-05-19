import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/labour_provider.dart';
import '../models/role_settings.dart';
import '../models/service_intent.dart';
import '../models/service_request.dart';
import '../models/user_profile.dart';
import '../models/user_preferences.dart';
import '../models/user_role.dart';
import '../models/chat_session.dart';
import '../services/chat_api_service.dart';
import '../services/intent_parser_service.dart';
import '../services/notification_service.dart';
import '../services/preferences_repository.dart';
import '../services/provider_matcher_service.dart';
import '../services/requests_repository.dart';
import '../services/session_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/map_picker_screen.dart';
import '../widgets/provider_match_card.dart';
import '../widgets/requests_panel.dart';
import '../widgets/settings_panel.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/customer_chat_list_panel.dart';

enum _Tab { chats, assistant, requests, settings }

const _introAgent =
    'Assalamu Alaikum! Main Ustaad AI hoon. Batayein — kaunsi service chahiye, kahan, aur kab?';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onSwitchRole,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback onSwitchRole;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  _Tab _tab = _Tab.chats;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  RoleSettings _settings = const RoleSettings();
  String? _sessionId;
  List<Map<String, dynamic>> _messages = [];
  ServiceIntent _intent = const ServiceIntent();
  String? _lastClarificationMessage;
  List<String> _rejectedIds = [];
  bool _isLoading = false;
  List<ServiceRequest> _requests = [];
  List<ChatSession> _sessions = [];
  StreamSubscription? _reqSub;
  final Set<String> _notifiedStatuses = {};
  bool _requestsListenerReady = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _settings = await PreferencesRepository.instance.loadRole(uid, UserRole.customer);
    // Always start a new chat session when the app opens
    _sessionId = await SessionRepository.instance.createSession(uid);
    _sessions = await SessionRepository.instance.listSessions(uid);
    setState(() {
      _messages = [{'role': 'agent', 'text': _introAgent}];
      _intent = const ServiceIntent();
      _rejectedIds = [];
    });
    _reqSub = RequestsRepository.instance.watchCustomerRequests(uid).listen((list) {
      if (!_requestsListenerReady) {
        _requestsListenerReady = true;
        for (final r in list) {
          _notifiedStatuses.add('${r.id}_${r.status}');
        }
        if (mounted) setState(() => _requests = list);
        return;
      }
      for (final r in list) {
        final key = '${r.id}_${r.status}';
        if (_notifiedStatuses.add(key)) {
          _onRequestStatus(r);
        }
      }
      if (mounted) setState(() => _requests = list);
    });
    if (mounted) setState(() {});
  }

  Future<void> _onRequestStatus(ServiceRequest r) async {
    final msg = RequestsRepository.customerChatMessageForStatus(r.status);
    if (msg != null) {
      await NotificationService.instance.showInstant('Request update', msg);
    }
    if (_sessionId == r.sessionId && mounted) {
      await _loadSession(_sessionId!);
    }
  }

  Future<void> _loadSession(String sessionId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final msgs = await SessionRepository.instance.loadMessages(uid, sessionId);
    _intent = await SessionRepository.instance.loadIntent(uid, sessionId);
    _rejectedIds = await SessionRepository.instance.loadRejectedIds(uid, sessionId);
    setState(() {
      _sessionId = sessionId;
      _messages = msgs.isEmpty ? [{'role': 'agent', 'text': _introAgent}] : msgs;
    });
  }

  Future<void> _newSession() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final id = await SessionRepository.instance.createSession(uid);
    setState(() {
      _sessionId = id;
      _messages = [{'role': 'agent', 'text': _introAgent}];
      _intent = const ServiceIntent();
      _rejectedIds = [];
    });
    _sessions = await SessionRepository.instance.listSessions(uid);
  }

  String _userConversationHistory({bool includeLatest = true}) {
    final lines = <String>[];
    final limit = includeLatest ? _messages.length : _messages.length - 1;
    for (var i = 0; i < limit; i++) {
      final m = _messages[i];
      if (m['role'] == 'user') {
        lines.add('User: ${m['text']}');
      }
    }
    return lines.join('\n');
  }

  Future<({ServiceIntent intent, bool fromServer})> _parseIntent(String message) async {
    final history = _userConversationHistory(includeLatest: false);
    try {
      final api = await ChatApiService.instance.parseIntent(
        message: message,
        history: history.isEmpty ? null : history,
        defaultLocation: _settings.defaultLocation,
      );
      _lastClarificationMessage = api.clarificationNeeded ? api.clarificationMessage : null;
      return (
        intent: ServiceIntent(
          service: api.service,
          location: api.location,
          time: api.time,
        ),
        fromServer: true,
      );
    } catch (_) {
      _lastClarificationMessage = null;
      return (
        intent: IntentParserService.instance.parseMessage(
          message,
          defaultLocation: _settings.defaultLocation,
        ),
        fromServer: false,
      );
    }
  }

  String _resolveInput(String text) {
    final t = text.trim();
    final lower = t.toLowerCase();
    if (lower == 'default location' ||
        lower == 'default' ||
        lower == 'meri default location') {
      return _settings.defaultLocation.isNotEmpty
          ? _settings.defaultLocation
          : t;
    }
    return t;
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _sessionId == null) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final trimmed = _resolveInput(text);

    setState(() {
      _messages.add({'role': 'user', 'text': trimmed});
      _isLoading = true;
    });
    _controller.clear();
    _scrollBottom();

    await SessionRepository.instance.saveMessage(
      uid: uid,
      sessionId: _sessionId!,
      role: 'user',
      text: trimmed,
    );

    final parseResult = await _parseIntent(trimmed);

    final canStartNew = await RequestsRepository.instance.sessionCanStartNewBooking(
      customerUid: uid,
      sessionId: _sessionId!,
    );

    ServiceIntent merged;
    if (parseResult.fromServer) {
      merged = parseResult.intent;
    } else if (canStartNew &&
        IntentParserService.instance.shouldResetIntent(
          trimmed,
          parseResult.intent,
          _intent,
        )) {
      merged = const ServiceIntent().merge(parseResult.intent);
    } else {
      merged = _intent.merge(parseResult.intent);
    }

    if ((merged.location == null || merged.location!.isEmpty) &&
        _settings.defaultLocation.isNotEmpty &&
        merged.service != null &&
        merged.time != null &&
        parseResult.intent.location == null) {
      merged = merged.merge(ServiceIntent(location: _settings.defaultLocation));
    }

    _intent = merged;
    await SessionRepository.instance.saveIntent(uid, _sessionId!, _intent);

    if (!canStartNew && _intent.isComplete) {
      await _addAgent(
        'Aapki pehli request abhi chal rahi hai. Updates Requests tab mein dekhein. '
        'Nayi service tab book kar sakte hain jab pehli request complete/rated ho jaye.',
      );
      setState(() => _isLoading = false);
      return;
    }

    if (!_intent.isComplete) {
      final missing = _intent.nextMissingField!;
      final reply = _lastClarificationMessage ??
          IntentParserService.instance.promptForMissing(
            missing,
            hintFromCode(_settings.language.code),
            current: _intent,
          );
      _lastClarificationMessage = null;
      await _addAgent(reply);
      setState(() => _isLoading = false);
      return;
    }

    final provider = ProviderMatcherService.instance.nextProvider(
      _intent,
      rejectedIds: _rejectedIds,
    );

    if (provider == null) {
      final svc = _intent.service ?? 'service';
      await _addAgent(ProviderMatcherService.instance.noProviderMessage(svc));
      setState(() => _isLoading = false);
      return;
    }

    await _addAgent(
      ProviderMatcherService.instance.matchExplanation(provider),
      provider: provider.toMap(),
    );
    setState(() => _isLoading = false);
  }

  Future<String?> _addAgent(String text, {Map<String, dynamic>? provider}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final id = await SessionRepository.instance.saveMessage(
      uid: uid,
      sessionId: _sessionId!,
      role: 'agent',
      text: text,
      provider: provider,
    );
    setState(() {
      _messages.add({
        'id': id,
        'role': 'agent',
        'text': text,
        if (provider != null) 'provider': provider,
      });
    });
    _scrollBottom();
    return id;
  }

  Future<void> _rejectProvider(int messageIndex) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final msg = _messages[messageIndex];
    final prov = msg['provider'] as Map<String, dynamic>?;
    if (prov != null) {
      _rejectedIds = [..._rejectedIds, prov['id'] as String];
      await SessionRepository.instance.saveRejectedIds(uid, _sessionId!, _rejectedIds);
    }
    setState(() => _isLoading = true);
    final next = ProviderMatcherService.instance.nextProvider(
      _intent,
      rejectedIds: _rejectedIds,
    );
    if (next == null) {
      await _addAgent(
        ProviderMatcherService.instance.noProviderMessage(_intent.service ?? 'service'),
      );
    } else {
      await _addAgent(
        ProviderMatcherService.instance.matchExplanation(next),
        provider: next.toMap(),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _bookProvider(int messageIndex) async {
    final msg = _messages[messageIndex];
    if (msg['booked'] == true) return;

    final providerMap = msg['provider'] as Map<String, dynamic>?;
    if (providerMap == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final provider = LabourProvider.fromMap(providerMap);
    final name = _settings.displayName.isNotEmpty
        ? _settings.displayName
        : FirebaseAuth.instance.currentUser?.displayName ?? 'Customer';

    try {
      final req = await RequestsRepository.instance.createFromBooking(
        customerUid: uid,
        customerName: name,
        intent: _intent,
        provider: provider,
        sessionId: _sessionId!,
      );

      final messageId = msg['id'] as String?;
      if (messageId != null) {
        await SessionRepository.instance.markMessageBooked(
          uid,
          _sessionId!,
          messageId,
          requestId: req.id,
        );
      }

      setState(() {
        _messages[messageIndex] = {
          ...msg,
          'booked': true,
          'requestId': req.id,
        };
        _messages.add({'role': 'user', 'text': 'Request sent'});
      });

      await SessionRepository.instance.saveMessage(
        uid: uid,
        sessionId: _sessionId!,
        role: 'user',
        text: 'Request sent',
      );

      try {
        if (req.scheduledAt != null) {
          await NotificationService.instance.scheduleServiceReminder(
            id: req.id.hashCode,
            title: 'Ustaad AI reminder',
            body: '${req.service} at ${req.time}',
            when: req.scheduledAt!,
          );
        }
      } catch (_) {
        // Reminder optional if scheduling not permitted on device.
      }

      setState(() => _tab = _Tab.requests);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveSettings(RoleSettings s) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await PreferencesRepository.instance.saveRole(uid, UserRole.customer, s);
    setState(() => _settings = s);
  }

  Future<void> _openMap() async {
    final loc = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (loc != null) await _send(loc);
  }

  @override
  void dispose() {
    _reqSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kWhite,
      drawer: _drawer(user),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: kText),
        title: const Text('Ustaad AI', style: TextStyle(fontFamily: 'Flaviotte', color: kText, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: widget.onSwitchRole,
            child: const Text('Provider', style: TextStyle(color: kBlue, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          _tabBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                key: ValueKey<int>(_tab.index),
                width: double.infinity,
                height: double.infinity,
                child: _body(),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _tab == _Tab.assistant ? _inputBar() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBorder))),
      child: Row(
        children: [
          _tabBtn('Chats', _Tab.chats, Icons.forum_outlined),
          _tabBtn('Assistant', _Tab.assistant, Icons.smart_toy_outlined),
          _tabBtn('Requests', _Tab.requests, Icons.assignment_outlined, badge: _requests.length),
          _tabBtn('Settings', _Tab.settings, Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, _Tab tab, IconData icon, {int badge = 0}) {
    final on = _tab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: on ? kBlue : Colors.transparent, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: on ? kBlue : kTextMuted),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: on ? kBlue : kTextMuted)),
              if (badge > 0) Text(' ($badge)', style: const TextStyle(fontSize: 10, color: kBlue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_tab == _Tab.chats) {
      return CustomerChatListPanel(
        requests: _requests,
        customerName: _settings.displayName.isNotEmpty
            ? _settings.displayName
            : 'Customer',
        onAssistantTap: () => setState(() => _tab = _Tab.assistant),
      );
    }
    if (_tab == _Tab.requests) {
      return RequestsPanel(
        requests: _requests,
        isProvider: false,
        currentUserName: _settings.displayName.isNotEmpty
            ? _settings.displayName
            : 'Customer',
        onVerifyComplete: (r) => RequestsRepository.instance.updateStatus(r.id, 'COMPLETED'),
        onRate: (r, stars, fb) async {
          await RequestsRepository.instance.updateStatus(
            r.id,
            'RATED',
            rating: stars,
            feedback: fb,
          );
          if (_sessionId == r.sessionId) {
            _intent = const ServiceIntent();
            await SessionRepository.instance.saveIntent(
              FirebaseAuth.instance.currentUser!.uid,
              _sessionId!,
              _intent,
            );
            await _loadSession(_sessionId!);
          }
        },
      );
    }
    if (_tab == _Tab.settings) {
      return SettingsPanel(
        settings: _settings,
        email: FirebaseAuth.instance.currentUser?.email,
        isProvider: false,
        onSave: _saveSettings,
      );
    }
    return Column(
      children: [
        if (_intent.service != null || _intent.location != null || _intent.time != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kBlueLight, borderRadius: BorderRadius.circular(10)),
            child: Text(_intent.summary(), style: const TextStyle(fontSize: 11)),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _messages.length) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator(color: kBlue)),
                );
              }
              return _bubble(_messages[i], i);
            },
          ),
        ),
      ],
    );
  }

  Widget _bubble(Map<String, dynamic> m, int index) {
    final isUser = m['role'] == 'user';
    final prov = m['provider'] as Map<String, dynamic>?;
    final booked = m['booked'] == true;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? kBlue : kSurface,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m['text'] as String, style: TextStyle(color: isUser ? kWhite : kText)),
            if (prov != null)
              ProviderMatchCard(
                provider: prov,
                booked: booked,
                onBook: booked ? null : () => _bookProvider(index),
                onReject: booked ? null : () => _rejectProvider(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(color: kWhite, border: Border(top: BorderSide(color: kBorder))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.map_outlined, color: kBlue), onPressed: _openMap),
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: _settings.language.isRtl ? TextDirection.rtl : TextDirection.ltr,
              decoration: const InputDecoration(
                hintText: 'Type service, location, time…',
                border: InputBorder.none,
              ),
              onSubmitted: _send,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: kBlue),
            onPressed: () => _send(_controller.text),
          ),
        ],
      ),
    );
  }

  Widget _drawer(User? user) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            ListTile(
              leading: ProfileAvatar(
                imageUrl: _settings.photoUrl.isNotEmpty
                    ? _settings.photoUrl
                    : user?.photoURL,
                size: 48,
              ),
              title: Text(_settings.displayName.isNotEmpty ? _settings.displayName : 'Customer'),
              subtitle: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.add_comment, color: kBlue),
              title: const Text('New chat session'),
              onTap: () {
                Navigator.pop(context);
                _newSession();
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Chat history', style: TextStyle(fontWeight: FontWeight.w700, color: kTextMuted)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (_, i) {
                  final s = _sessions[i];
                  return ListTile(
                    title: Text(s.title),
                    subtitle: Text(s.intentSummary, maxLines: 1),
                    selected: s.id == _sessionId,
                    onTap: () {
                      Navigator.pop(context);
                      _loadSession(s.id);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: kText),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _tab = _Tab.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
