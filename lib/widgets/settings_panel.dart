import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/role_settings.dart';
import '../models/user_preferences.dart';
import '../models/user_role.dart';
import '../services/google_auth_service.dart';
import '../services/profile_image_processor.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/profile_validators.dart';
import 'profile_avatar.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,
    required this.settings,
    required this.email,
    required this.isProvider,
    required this.onSave,
  });

  final RoleSettings settings;
  final String? email;
  final bool isProvider;
  final ValueChanged<RoleSettings> onSave;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late AppLanguage _language;
  late TextEditingController _locationCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _slotsCtrl;
  late String _providerService;
  String _photoUrl = '';
  Uint8List? _localPhotoBytes;
  bool _saving = false;

  // Day-of-week toggle state
  late List<bool> _selectedDays; // Mon=0, Tue=1, ..., Sun=6

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _language = s.language;
    _locationCtrl = TextEditingController(text: s.defaultLocation);
    _nameCtrl = TextEditingController(text: s.displayName);
    _phoneCtrl = TextEditingController(text: s.phone);
    _ageCtrl = TextEditingController(text: s.age?.toString() ?? '');
    _dobCtrl = TextEditingController(text: s.dateOfBirth);
    _slotsCtrl = TextEditingController(text: s.availableSlots);
    _providerService = s.providerServiceType;
    _photoUrl = s.photoUrl;

    // Initialize day selection from the stored availableDays
    final dayNumbers = s.dayNumbers;
    _selectedDays = List.generate(7, (i) {
      if (dayNumbers.isEmpty) return i < 5; // Default Mon-Fri
      return dayNumbers.contains(i + 1); // dayNumbers is 1-indexed
    });
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _dobCtrl.dispose();
    _slotsCtrl.dispose();
    super.dispose();
  }

  /// Build the compact day range string from selected toggles.
  /// E.g. [true, true, true, true, true, false, false] → "Mon-Fri"
  /// E.g. [true, true, true, false, true, true, false] → "Mon-Wed, Fri-Sat"
  String _buildDayRangeString() {
    final ranges = <String>[];
    int? rangeStart;

    for (var i = 0; i < 7; i++) {
      if (_selectedDays[i]) {
        rangeStart ??= i;
      } else {
        if (rangeStart != null) {
          if (rangeStart == i - 1) {
            ranges.add(_dayLabels[rangeStart]);
          } else {
            ranges.add('${_dayLabels[rangeStart]}-${_dayLabels[i - 1]}');
          }
          rangeStart = null;
        }
      }
    }
    // Close any trailing range
    if (rangeStart != null) {
      if (rangeStart == 6) {
        ranges.add(_dayLabels[6]);
      } else {
        ranges.add('${_dayLabels[rangeStart]}-${_dayLabels[6]}');
      }
    }
    return ranges.isEmpty ? 'Mon-Fri' : ranges.join(', ');
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    try {
      final bytes = await ProfileImageProcessor.processFile(File(picked.path));
      setState(() => _localPhotoBytes = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo error: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    final nameCheck = ProfileValidators.validateName(_nameCtrl.text);
    if (!nameCheck.ok) {
      _showError(nameCheck.error!);
      return;
    }
    final phoneCheck = ProfileValidators.validatePhone(_phoneCtrl.text);
    if (!phoneCheck.ok) {
      _showError(phoneCheck.error!);
      return;
    }
    final ageCheck = ProfileValidators.validateAge(_ageCtrl.text);
    if (!ageCheck.ok) {
      _showError(ageCheck.error!);
      return;
    }
    final dobCheck = ProfileValidators.validateDob(_dobCtrl.text);
    if (!dobCheck.ok) {
      _showError(dobCheck.error!);
      return;
    }

    setState(() => _saving = true);
    try {
      var photo = _photoUrl;
      if (_localPhotoBytes != null) {
        final role = widget.isProvider ? UserRole.provider : UserRole.customer;
        photo = await StorageService.instance.uploadProfilePhoto(_localPhotoBytes!, role.code);
      }
      final settings = RoleSettings(
        displayName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        defaultLocation: _locationCtrl.text.trim(),
        language: _language,
        photoUrl: photo,
        age: int.tryParse(_ageCtrl.text.trim()),
        dateOfBirth: _dobCtrl.text.trim(),
        providerServiceType: _providerService,
        availableSlots: _slotsCtrl.text.trim(),
        availableDays: _buildDayRangeString(),
        isProviderOnline: widget.settings.isProviderOnline,
      );
      setState(() {
        _photoUrl = photo;
        _localPhotoBytes = null;
      });
      widget.onSave(settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.isProvider ? 'Provider settings' : 'Customer settings',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText),
        ),
        const SizedBox(height: 16),
        Center(
          child: ProfileAvatar(
            imageUrl: _photoUrl,
            imageBytes: _localPhotoBytes,
            onTap: _pickPhoto,
            showCameraHint: true,
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Tap to change photo (saved as 64×64)',
            style: TextStyle(fontSize: 11, color: kTextMuted),
          ),
        ),
        const SizedBox(height: 20),
        _field('Full name', _nameCtrl),
        const SizedBox(height: 12),
        _field('Phone number', _phoneCtrl, keyboard: TextInputType.phone),
        const SizedBox(height: 12),
        _field('Age', _ageCtrl, keyboard: TextInputType.number),
        const SizedBox(height: 12),
        _field('Date of birth', _dobCtrl, hint: 'DD/MM/YYYY'),
        const SizedBox(height: 12),
        _field('Default location', _locationCtrl),
        const SizedBox(height: 16),
        const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<AppLanguage>(
          initialValue: _language,
          items: AppLanguage.values.map((l) => DropdownMenuItem(value: l, child: Text(l.label))).toList(),
          onChanged: (v) => setState(() => _language = v ?? _language),
        ),
        if (widget.isProvider) ...[
          const SizedBox(height: 16),
          const Text('Default labour type', style: TextStyle(fontWeight: FontWeight.w700, color: kGoldenBeige)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: kProviderServiceTypes.contains(_providerService)
                ? _providerService
                : kProviderServiceTypes.first,
            items: kProviderServiceTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _providerService = v ?? _providerService),
          ),
          const SizedBox(height: 16),
          _field(
            'Available timings (intervals)',
            _slotsCtrl,
            hint: '9am-1pm, 3pm-6pm',
          ),
          const SizedBox(height: 4),
          const Text(
            'Use intervals like 8am-12pm. Separate multiple with commas.',
            style: TextStyle(fontSize: 10, color: kTextMuted),
          ),
          const SizedBox(height: 16),
          const Text('Available days', style: TextStyle(fontWeight: FontWeight.w700, color: kGoldenBeige)),
          const SizedBox(height: 8),
          _dayToggleRow(),
          const SizedBox(height: 6),
          Text(
            _buildDayRangeString(),
            style: const TextStyle(fontSize: 12, color: kTextMuted, fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isProvider ? kGoldenBeige : kBlue,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kWhite))
                : const Text('Save settings'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => GoogleAuthService.instance.signOut(),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  /// Row of 7 day toggle chips (Mon–Sun) with color feedback.
  Widget _dayToggleRow() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(7, (i) {
        final selected = _selectedDays[i];
        return GestureDetector(
          onTap: () => setState(() => _selectedDays[i] = !_selectedDays[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? kGoldenBeige : kSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? kGoldenBeige : kBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              _dayLabels[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? kWhite : kTextMuted,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: kText)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
