import '../models/service_intent.dart';
import '../models/user_role.dart';

/// Extracts service, location, and time from free-form user text (incremental-friendly).
class IntentParserService {
  IntentParserService._();
  static final IntentParserService instance = IntentParserService._();

  static final List<_ServiceEntry> _catalog = [
    _ServiceEntry('Plumber', [
      'plumber', 'plumbing', 'plumbur', 'plumbr', 'nalkay', 'nalkey', 'pipe', 'leak', 'tap',
    ]),
    _ServiceEntry('Electrician', [
      'electrician', 'electrition', 'electric', 'bijli', 'wiring', 'wire',
    ]),
    _ServiceEntry('AC Technician', [
      'ac technician', 'air conditioner', 'aircondition', 'air condition', 'hvac', 'cooling', 'ac',
    ]),
    _ServiceEntry('Beautician', ['beautician', 'beautition', 'salon', 'makeup', 'facial']),
    _ServiceEntry('Carpenter', ['carpenter', 'carpentr', 'lakri', 'furniture', 'woodwork']),
    _ServiceEntry('Painter', ['painter', 'painting', 'distemper']),
    _ServiceEntry('Mason', ['mason', 'cement work', 'tiles work']),
    _ServiceEntry('Generator Repair', ['generator', 'genrator', 'genset']),
  ];

  static final _timePattern = RegExp(
    r'(kal|aaj|tomorrow|today|subah|subha|sham|shaam|morning|evening|night|raat|din|afternoon|'
    r'parson|agla|next)\s*'
    r'(\d{1,2})?\s*(:\d{2})?\s*(baje|bje|am|pm)?|'
    r'\d{1,2}\s*(:\d{2})?\s*(am|pm|baje|bje)',
    caseSensitive: false,
  );

  static final _coordPattern = RegExp(r'^-?\d+\.?\d*\s*,\s*-?\d+\.?\d*$');

  static const _newBookingPhrases = [
    'new request', 'another service', 'another', 'dobara', 'phir se', 'ek aur',
    'new booking', 'nayi request', 'dosra', 'doosra', 'change service', 'alag service',
  ];

  ServiceIntent parseMessage(String text, {String? defaultLocation}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const ServiceIntent();

    final lower = _normalize(trimmed);

    if (_isDefaultLocationPhrase(lower)) {
      if (defaultLocation != null && defaultLocation.trim().isNotEmpty) {
        return ServiceIntent(location: defaultLocation.trim());
      }
    }

    if (_coordPattern.hasMatch(trimmed)) {
      return ServiceIntent(location: trimmed);
    }

    final service = _detectService(lower, trimmed);
    var remainder = trimmed;
    if (service != null) {
      remainder = _stripServiceMentions(remainder, service);
    }

    String? time = _extractTimePhrase(remainder);
    if (time != null) {
      remainder = remainder.replaceFirst(time, ' ').trim();
    }

    String? location = _extractLocationPhrase(remainder, lower);
    if (location == null && time == null && service == null) {
      location = _fallbackLocation(trimmed, lower);
    }

    if (location != null && time != null && _normalize(location) == _normalize(time)) {
      if (_looksLikeTimeOnly(_normalize(trimmed))) {
        location = null;
      } else if (!_looksLikeTimeOnly(_normalize(trimmed))) {
        time = null;
      }
    }

    return ServiceIntent(service: service, location: location, time: time);
  }

  /// Reset intent only for a genuinely new booking — not when user adds time/location only.
  bool shouldResetIntent(String text, ServiceIntent parsed, ServiceIntent current) {
    final lower = _normalize(text);
    if (_newBookingPhrases.any((p) => lower.contains(p))) return true;
    if (parsed.service != null &&
        current.service != null &&
        parsed.service != current.service) {
      return true;
    }
    if (parsed.service != null &&
        current.service == null &&
        current.location == null &&
        current.time == null) {
      return true;
    }
    return false;
  }

  @Deprecated('Use shouldResetIntent')
  bool looksLikeNewBookingAttempt(String text, ServiceIntent parsed) =>
      shouldResetIntent(text, parsed, const ServiceIntent());

  String promptForMissing(String field, AppLanguageHint lang, {ServiceIntent? current}) {
    final hasLoc = current?.location != null && current!.location!.trim().isNotEmpty;
    switch (field) {
      case 'service':
        return _t(
          lang,
          'Which service do you need? (e.g. plumber, electrician)',
          'Kaunsi service chahiye? (jaise plumber, electrician)',
          'کون سی سروس چاہیے؟',
        );
      case 'location':
        if (hasLoc) {
          return _t(
            lang,
            'Got it. When do you need the service? (e.g. tomorrow 10 AM)',
            'Theek hai. Kab chahiye? (jaise kal subah 10 baje)',
            'کب چاہیے؟',
          );
        }
        return _t(
          lang,
          'Where do you need it? Share area and city (e.g. Gulshan, Karachi).',
          'Kahan chahiye? Area aur shehar batayein (jaise Gulshan, Karachi).',
          'کہاں چاہیے؟ علاقہ اور شہر بتائیں۔',
        );
      case 'time':
        return _t(
          lang,
          'When do you need it? (e.g. kal subah 10 baje)',
          'Kab chahiye? (jaise kal subah 10 baje)',
          'کب چاہیے؟',
        );
      default:
        return 'Please share more details.';
    }
  }

  String? _detectService(String lower, String original) {
    String? best;
    var bestScore = 0;

    for (final entry in _catalog) {
      for (final alias in entry.aliases) {
        final score = _aliasScore(lower, original, alias);
        if (score > bestScore) {
          bestScore = score;
          best = entry.name;
        }
      }
      final canonical = entry.name.toLowerCase();
      final score = _aliasScore(lower, original, canonical);
      if (score > bestScore) {
        bestScore = score;
        best = entry.name;
      }
    }

  for (final type in kProviderServiceTypes) {
      final score = _aliasScore(lower, original, type.toLowerCase());
      if (score > bestScore) {
        bestScore = score;
        best = type;
      }
    }

    return bestScore >= 4 ? best : null;
  }

  int _aliasScore(String lower, String original, String alias) {
    final a = _normalize(alias);
    if (a.isEmpty) return 0;

    if (a.length <= 3) {
      final re = RegExp(r'(?:^|\s)' + RegExp.escape(a) + r'(?:\s|$)');
      return re.hasMatch(lower) ? a.length + 8 : 0;
    }

    if (a.contains(' ')) {
      return lower.contains(a) ? a.length + 6 : 0;
    }

    final wordBoundary = RegExp(r'(?:^|\s)' + RegExp.escape(a) + r'(?:\s|$)');
    if (wordBoundary.hasMatch(lower)) return a.length + 5;

    if (a.length >= 5 && lower.contains(a)) return a.length + 2;

    var best = 0;
    for (final word in lower.split(RegExp(r'\s+'))) {
      if (word.length < 4) continue;
      if (_editDistance(word, a) <= 2 && a.length >= 5) {
        best = best > a.length ? best : a.length + 1;
      }
    }
    return best;
  }

  String _stripServiceMentions(String text, String serviceName) {
    var r = text;
    final entry = _catalog.firstWhere(
      (e) => e.name == serviceName,
      orElse: () => _ServiceEntry(serviceName, [serviceName.toLowerCase()]),
    );
    for (final alias in [...entry.aliases, serviceName.toLowerCase()]) {
      r = r.replaceAll(RegExp(alias, caseSensitive: false), ' ');
    }
    return r.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _extractTimePhrase(String text) {
    final m = _timePattern.firstMatch(text);
    if (m != null) return m.group(0)!.trim();
    final lower = _normalize(text);
    if (_looksLikeTimeOnly(lower)) return text.trim();
    return null;
  }

  String? _extractLocationPhrase(String remainder, String lowerFull) {
    final t = remainder.trim();
    if (t.isEmpty) return null;

    final lower = _normalize(t);
    if (_looksLikeTimeOnly(lower)) return null;

    // "Ferozpur my" / "G-13 mein" — location before postposition
    final postposition = RegExp(
      r'(.+?)\s+(?:mein|main|mai|me|my|par|pe)\s*$',
      caseSensitive: false,
    ).firstMatch(t);
    if (postposition != null) {
      final seg = _stripFillerWords(postposition.group(1)!.trim());
      if (seg.length >= 2 && !_looksLikeTimeOnly(_normalize(seg))) return seg;
    }

    final locTag = RegExp(
      r'(?:location|jagah|area|address|pata|at|in|par|pe|near)\s*[:\-]?\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(t);
    if (locTag != null) {
      final seg = _stripFillerWords(locTag.group(1)!.trim());
      if (seg.isNotEmpty && !_looksLikeTimeOnly(_normalize(seg))) return seg;
    }

    final parts = t.split(RegExp(r'[,;]')).map((e) => e.trim()).where((e) => e.isNotEmpty);
    for (final part in parts) {
      final cleaned = _stripFillerWords(part);
      if (cleaned.length >= 2 &&
          !_looksLikeTimeOnly(_normalize(cleaned)) &&
          !_looksLikeTimeOnly(_normalize(part))) {
        return cleaned;
      }
    }

    final stripped = _stripFillerWords(t);
    if (stripped.length >= 2 && !_looksLikeTimeOnly(_normalize(stripped))) {
      return stripped;
    }
    return null;
  }

  String _stripFillerWords(String text) {
    var r = text;
    const fillers = [
      'mujhy', 'mujhe', 'muje', 'chahye', 'chahiye', 'chaheye', 'chaiye',
      'please', 'bhejo', 'bhej', 'service', 'ka', 'ki', 'ke', 'ko',
    ];
    for (final f in fillers) {
      r = r.replaceAll(RegExp('\\b$f\\b', caseSensitive: false), ' ');
    }
    return r.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _fallbackLocation(String trimmed, String lower) {
    if (_looksLikeTimeOnly(lower)) return null;
    if (_detectService(lower, trimmed) != null && !_hasPlaceCue(lower)) return null;
    if (_hasPlaceCue(lower) || trimmed.length >= 4) return trimmed;
    return null;
  }

  bool _hasPlaceCue(String lower) {
    const cues = [
      'karachi', 'lahore', 'islamabad', 'rawalpindi', 'block', 'sector', 'gulshan',
      'dha', 'bahria', 'colony', 'road', 'street', 'phase', 'society', 'town', 'nagar',
    ];
    return cues.any((c) => lower.contains(c));
  }

  bool _looksLikeTimeOnly(String lower) {
    if (_timePattern.hasMatch(lower)) return true;
    const timeTokens = [
      'kal', 'aaj', 'subah', 'subha', 'sham', 'baje', 'bje', 'am', 'pm', 'morning',
      'evening', 'tomorrow', 'today',
    ];
    final words = lower.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return false;
    return words.every((w) => timeTokens.contains(w) || RegExp(r'^\d{1,2}$').hasMatch(w));
  }

  bool _isDefaultLocationPhrase(String lower) =>
      lower == 'default location' ||
      lower == 'default' ||
      lower.contains('meri default location');

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^\w\s:.,]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  int _editDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final m = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      m[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      m[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        m[i][j] = [
          m[i - 1][j] + 1,
          m[i][j - 1] + 1,
          m[i - 1][j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
    }
    return m[a.length][b.length];
  }

  String _t(AppLanguageHint lang, String en, String rom, String ur) {
    switch (lang) {
      case AppLanguageHint.english:
        return en;
      case AppLanguageHint.urdu:
        return ur;
      case AppLanguageHint.romanUrdu:
        return rom;
    }
  }
}

class _ServiceEntry {
  const _ServiceEntry(this.name, this.aliases);
  final String name;
  final List<String> aliases;
}

enum AppLanguageHint { english, urdu, romanUrdu }

AppLanguageHint hintFromCode(String code) {
  switch (code) {
    case 'English':
      return AppLanguageHint.english;
    case 'Urdu':
      return AppLanguageHint.urdu;
    default:
      return AppLanguageHint.romanUrdu;
  }
}
