import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/role_settings.dart';
import '../models/service_request.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../services/notification_service.dart';
import '../services/preferences_repository.dart';
import '../services/requests_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/requests_panel.dart';
import '../widgets/settings_panel.dart';
import '../widgets/provider_chat_list_panel.dart';

enum _PTab { chat, requests, settings }

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onSwitchRole,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback onSwitchRole;

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  _PTab _tab = _PTab.requests;
  RoleSettings _settings = const RoleSettings();
  List<ServiceRequest> _inbox = [];
  List<ServiceRequest> _active = [];
  StreamSubscription? _inboxSub;
  StreamSubscription? _activeSub;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final s = await PreferencesRepository.instance.loadRole(uid, UserRole.provider);
    setState(() {
      _settings = s;
      _online = s.isProviderOnline;
    });
    _listen();
  }

  void _listen() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _inboxSub?.cancel();
    _activeSub?.cancel();
    _inboxSub = RequestsRepository.instance
        .watchProviderInbox(
          providerService: _settings.providerServiceType,
          isOnline: _online,
        )
        .listen((l) {
      if (mounted) setState(() => _inbox = l);
    });
    _activeSub = RequestsRepository.instance.watchProviderActive(uid).listen((l) {
      if (mounted) setState(() => _active = l);
    });
  }

  List<ServiceRequest> get _allRequests {
    final ids = <String>{};
    final merged = <ServiceRequest>[];
    for (final r in [..._inbox, ..._active]) {
      if (ids.add(r.id)) merged.add(r);
    }
    merged.sort((a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return merged;
  }

  Future<void> _setOnline(bool v) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final updated = _settings.copyWith(isProviderOnline: v);
    await PreferencesRepository.instance.saveRole(uid, UserRole.provider, updated);
    setState(() {
      _online = v;
      _settings = updated;
    });
    _listen();
  }

  Future<void> _accept(ServiceRequest r) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final name = _settings.displayName.isNotEmpty
        ? _settings.displayName
        : FirebaseAuth.instance.currentUser?.displayName ?? 'Provider';
    await RequestsRepository.instance.updateStatus(
      r.id,
      'ACCEPTED',
      providerUid: uid,
      providerName: name,
    );
  }

  Future<void> _status(ServiceRequest r, String status) async {
    await RequestsRepository.instance.updateStatus(r.id, status);
    await NotificationService.instance.showInstant('Status updated', status);
  }

  Future<void> _saveSettings(RoleSettings s) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await PreferencesRepository.instance.saveRole(uid, UserRole.provider, s);
    setState(() => _settings = s);
    _listen();
  }

  @override
  void dispose() {
    _inboxSub?.cancel();
    _activeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kGoldenBeige.withValues(alpha: 0.12),
        title: const Text(
          'Provider Portal',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        actions: [
          Text(_online ? 'Online' : 'Offline', style: TextStyle(fontSize: 12, color: _online ? kGoldenBeige : kTextMuted)),
          Switch(value: _online, activeThumbColor: kGoldenBeige, onChanged: _setOnline),
          TextButton(onPressed: widget.onSwitchRole, child: const Text('Customer', style: TextStyle(fontSize: 11))),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.handyman, color: kGoldenBeige),
                const SizedBox(width: 8),
                Text(_settings.providerServiceType, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(child: _tabChip('Chat', _PTab.chat)),
              Expanded(child: _tabChip('Requests (${_allRequests.length})', _PTab.requests)),
              Expanded(child: _tabChip('Settings', _PTab.settings)),
            ],
          ),
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
                child: _tab == _PTab.chat
                    ? ProviderChatListPanel(
                        requests: _allRequests,
                        providerName: _settings.displayName.isNotEmpty
                            ? _settings.displayName
                            : FirebaseAuth.instance.currentUser?.displayName ?? 'Provider',
                      )
                    : _tab == _PTab.settings
                    ? SettingsPanel(
                        settings: _settings,
                        email: FirebaseAuth.instance.currentUser?.email,
                        isProvider: true,
                        onSave: _saveSettings,
                      )
                    : _online
                        ? RequestsPanel(
                            requests: _allRequests,
                            isProvider: true,
                            currentUserName: _settings.displayName.isNotEmpty
                                ? _settings.displayName
                                : FirebaseAuth.instance.currentUser?.displayName ?? 'Provider',
                            onAccept: _accept,
                            onDecline: (r) => RequestsRepository.instance.decline(r.id),
                            onMove: (r) => _status(r, 'ON_THE_WAY'),
                            onArrived: (r) => _status(r, 'ARRIVED'),
                            onComplete: (r) => _status(r, 'COMPLETION_REQUESTED'),
                          )
                        : const Center(child: Text('Go online to receive requests')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(String label, _PTab tab) {
    final on = _tab == tab;
    return InkWell(
      onTap: () => setState(() => _tab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: on ? kGoldenBeige : Colors.transparent, width: 2)),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: on ? kGoldenBeige : kTextMuted)),
      ),
    );
  }
}
