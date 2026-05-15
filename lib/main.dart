import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'config.dart';
import 'services/chat_repository.dart';
import 'services/google_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const UstaadAiApp());
}

// ─── Theme Colors ────────────────────────────────────────────────────────────
const kBlue = Color(0xFF1A6BFF);
const kBlueDark = Color(0xFF0A4FD6);
const kBlueLight = Color(0xFFE8F0FF);
const kBlueMid = Color(0xFF5B9BFF);
const kWhite = Colors.white;
const kText = Color(0xFF0D1B3E);
const kTextMuted = Color(0xFF8A9BB8);
const kSurface = Color(0xFFF4F7FF);
const kBorder = Color(0xFFE2E9FF);

class UstaadAiApp extends StatelessWidget {
  const UstaadAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ustaad AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kWhite,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: kBlue),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: kBlue)),
            );
          }
          if (snapshot.hasData) {
            return const UstaadAiScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class UstaadAiScreen extends StatefulWidget {
  const UstaadAiScreen({super.key});

  @override
  State<UstaadAiScreen> createState() => _UstaadAiScreenState();
}

class _UstaadAiScreenState extends State<UstaadAiScreen>
    with TickerProviderStateMixin {
  bool isChatting = false;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _transitionController;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;
  late Animation<Offset> _glowPosition;
  late Animation<double> _uSize;
  late Animation<double> _chatOpacity;
  late Animation<double> _welcomeOpacity;

  static const _welcomeMessage = {
    'role': 'agent',
    'text': 'As-salamu alaykum! Apko kaunsi service chahiye?',
  };

  @override
  void initState() {
    super.initState();

    _messages.add(Map<String, dynamic>.from(_welcomeMessage));
    _loadChatHistory();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _glowScale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeInExpo),
      ),
    );

    _glowOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _glowPosition = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.5, -0.5),
    ).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeInCubic),
      ),
    );

    _uSize = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _chatOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _welcomeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final history =
          await ChatRepository.instance.loadMessages(user.uid);
      if (!mounted || history.isEmpty) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(history);
        isChatting = true;
      });
      _transitionController.value = 1.0;
      _scrollToBottom();
    } catch (_) {
      // Firestore rules or network issues — keep welcome message.
    }
  }

  void startChat() {
    if (!isChatting) {
      setState(() => isChatting = true);
      _transitionController.forward();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    startChat();

    setState(() {
      _messages.add({'role': 'user', 'text': text.trim()});
      isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final trimmed = text.trim();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ChatRepository.instance.saveMessage(
          uid: user.uid,
          text: trimmed,
          role: 'user',
        );
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/chat');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': trimmed,
          if (user != null) 'uid': user.uid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final agentText = data['text'] ?? 'Sorry, I encountered an error.';
        
        setState(() {
          _messages.add({
            'role': 'agent',
            'text': agentText,
          });
        });

        if (user != null) {
          await ChatRepository.instance.saveMessage(
            uid: user.uid,
            text: agentText,
            role: 'agent',
          );
        }
      } else {
        setState(() {
          _messages.add({
            'role': 'agent',
            'text':
                'Error: Server returned ${response.statusCode}. Make sure Next.js is running.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'agent',
          'text':
              'Network error. Please ensure the server is running.',
        });
      });
    } finally {
      setState(() => isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Drawer ──────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: const BoxDecoration(
              color: kBlue,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kWhite,
                    shape: BoxShape.circle,
                    image: user?.photoURL != null 
                      ? DecorationImage(image: NetworkImage(user!.photoURL!)) 
                      : null,
                    boxShadow: [
                      BoxShadow(
                        color: kBlueDark.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: user?.photoURL == null 
                    ? const Center(
                        child: Text(
                          'U',
                          style: TextStyle(
                            color: kBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ) 
                    : null,
                ),
                const SizedBox(height: 14),
                Text(
                  user?.displayName ?? 'Ustaad AI User',
                  style: const TextStyle(
                    color: kWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Har kaam ka ustaad',
                  style: TextStyle(
                    color: kWhite.withOpacity(0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _drawerItem(Icons.chat_bubble_outline_rounded, 'New Chat', () {
            Navigator.pop(context);
            setState(() {
              _messages.clear();
              _messages.add(Map<String, dynamic>.from(_welcomeMessage));
              isChatting = false;
              _transitionController.reset();
            });
          }),
          _drawerItem(Icons.history_rounded, 'Chat History', () => Navigator.pop(context)),
          _drawerItem(Icons.settings_outlined, 'Settings', () => Navigator.pop(context)),
          _drawerItem(Icons.logout_rounded, 'Sign Out', () async {
            Navigator.pop(context);
            await GoogleAuthService.instance.signOut();
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Ustaad AI v1.0',
              style: TextStyle(color: kTextMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: kBlueLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kBlue, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: kText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: kTextMuted, size: 20),
      onTap: onTap,
    );
  }

  // ─── Welcome Screen ───────────────────────────────────────────────────────
  Widget _buildWelcomeContent(Size size) {
    return AnimatedBuilder(
      animation: _welcomeOpacity,
      builder: (context, child) => Opacity(
        opacity: _welcomeOpacity.value,
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ustaad',
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.w800,
                    color: kBlue,
                    letterSpacing: -2.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'How can I help\nyou today?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: kText,
                    letterSpacing: 0.1,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Default message bubble
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kBlue.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: kBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'U',
                        style: TextStyle(
                          color: kBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _messages.isNotEmpty ? _messages[0]['text'] : '',
                      style: const TextStyle(
                        color: kText,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Chat Screen ─────────────────────────────────────────────────────────
  Widget _buildChatContent(Size size) {
    return AnimatedBuilder(
      animation: _chatOpacity,
      builder: (context, child) => Opacity(
        opacity: _chatOpacity.value,
        child: child,
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 68),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              itemCount: _messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: kBlueLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'U',
                              style: TextStyle(
                                color: kBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildTypingIndicator(),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['text'], isUser, size);
              },
            ),
          ),
          const SizedBox(height: 88),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
            child: _BouncingDot(delay: Duration(milliseconds: i * 160)),
          );
        }),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, Size size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: kBlueLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    color: kBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: size.width * 0.72),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: isUser ? kBlue : kSurface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isUser
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              border: isUser ? null : Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? kBlue.withOpacity(0.25)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isUser ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? kWhite : kText,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ─── Input Bar ────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: kWhite,
          border: Border(top: BorderSide(color: kBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: kBlue.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kBorder, width: 1.2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onTap: startChat,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type in Urdu, Roman Urdu or English...',
                          hintStyle: TextStyle(
                            color: kTextMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                        ),
                        style: const TextStyle(
                          color: kText,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        onSubmitted: sendMessage,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.mic_none_rounded,
                          color: kTextMuted, size: 22),
                      onPressed: startChat,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => sendMessage(_controller.text),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kBlue.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: kWhite,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Animated Glow / U Logo ───────────────────────────────────────────────
  // Welcome state: a soft blue cloud/light wash emanating from top-left corner.
  // No centered ball — the gradient origin is pinned to (0,0) top-left corner
  // and spreads diagonally down-right like a light source.
  // On chat start it contracts/sucks back into the corner and becomes a small
  // blue circle with "U" inside.
  Widget _buildAnimatedGlow(Size size) {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        final topPad = MediaQuery.of(context).padding.top;
        final t = _transitionController.value; // 0 = welcome, 1 = chat
        final isSmall = isChatting && t > 0.88;

        // ── Welcome: full-screen corner wash ──────────────────────────────
        // We paint a large square anchored at the top-left corner.
        // The RadialGradient focal point stays at topLeft so it looks like
        // light bleeding from the corner, not a centered sphere.
        if (!isChatting) {
          return IgnorePointer(
              child: SizedBox(
                width: size.width,
                height: size.height * 0.72,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.4,
                      colors: [
                        kBlueMid.withOpacity(0.95),
                        kBlue.withOpacity(0.80),
                        kBlue.withOpacity(0.45),
                        kBlue.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.22, 0.45, 0.70, 1.0],
                    ),
                  ),
                ),
              ),
            );
        }

        // ── Transition + Chat: shrink toward top-left, end as small circle ─
        // Glow wash fades + scales toward top-left corner
        final washOpacity = (1.0 - t * 1.6).clamp(0.0, 1.0);
        final washScale  = (1.0 - t).clamp(0.0, 1.0);

        // Small circle grows in at top-left after wash disappears
        final circleOpacity = ((t - 0.75) * 4.0).clamp(0.0, 1.0);
        final circleScale   = ((t - 0.75) * 4.0).clamp(0.0, 1.0);

        return Stack(
          children: [
            // Fading/shrinking wash anchored to top-left
            Positioned(
              top: 0,
              left: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: washOpacity,
                  child: Transform.scale(
                    scale: washScale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: size.width,
                      height: size.height * 0.72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.4,
                            colors: [
                              kBlueMid.withOpacity(0.95),
                              kBlue.withOpacity(0.80),
                              kBlue.withOpacity(0.45),
                              kBlue.withOpacity(0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.22, 0.45, 0.70, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Small blue circle appearing at top-left
            Positioned(
              top: topPad + 12,
              left: 16,
              child: GestureDetector(
                onTap: isSmall
                    ? () => _scaffoldKey.currentState?.openDrawer()
                    : null,
                child: Opacity(
                  opacity: circleOpacity,
                  child: Transform.scale(
                    scale: circleScale,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kBlue.withOpacity(0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'U',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Chat Header ──────────────────────────────────────────────────────────
  Widget _buildChatHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _chatOpacity,
        builder: (context, child) => Opacity(
          opacity: _chatOpacity.value,
          child: child,
        ),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 12,
            left: 72,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: kWhite,
            border: Border(bottom: BorderSide(color: kBorder, width: 1)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ustaad AI',
                    style: TextStyle(
                      color: kText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Online',
                        style: TextStyle(
                          color: kTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kWhite,
      drawer: _buildDrawer(),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Welcome content
          if (!isChatting || _transitionController.value < 0.7)
            _buildWelcomeContent(size),

          // Chat content
          _buildChatContent(size),

          // Chat header bar
          if (isChatting) _buildChatHeader(),

          // Animated blue glow / U circle
          _buildAnimatedGlow(size),

          // Input bar always on top
          _buildInputBar(),
        ],
      ),
    );
  }
}

// ─── Bouncing Dot for typing indicator ───────────────────────────────────────
class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: kBlueMid,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────
double? lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}