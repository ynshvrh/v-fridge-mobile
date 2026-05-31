import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/providers.dart';
import '../../theme/vf_colors.dart';
import '../../theme/vf_radius.dart';
import '../../widgets/animated_press.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final history = await ref.read(chatServiceProvider).history();
      if (mounted) setState(() { _messages = history; _loading = false; });
      _scrollToBottom();
    } on ApiError catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? overrideText]) async {
    final text = (overrideText ?? _input.text).trim();
    if (text.isEmpty || _sending) return;
    final rateLimitMessage = context.l10n.chatRateLimit;
    if (overrideText == null) _input.clear();
    setState(() {
      _messages = [..._messages, ChatMessage(id: -1, role: 'user', content: text)];
      _sending = true;
    });
    _scrollToBottom();
    try {
      final reply = await ref.read(chatServiceProvider).send(text);
      setState(() => _messages = [..._messages, reply]);
      // A small tap so the reply "lands" in the hand, not just on screen.
      HapticFeedback.lightImpact();
      _scrollToBottom();
    } on ApiError catch (e) {
      if (!mounted) return;
      if (e.status == 429) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(rateLimitMessage)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _clear() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatClearTitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.chatClearAction)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(chatServiceProvider).clear();
      setState(() => _messages = []);
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _ChatAppBar(onClear: _messages.isEmpty ? null : _clear),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _EmptyState(onPickPrompt: _send)
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: _messages.length + (_sending ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _messages.length) return const _TypingBubble();
                          final m = _messages[i];
                          return _Bubble(message: m);
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: InputDecoration(hintText: l10n.chatInputHint),
                      onSubmitted: (_) => _send(),
                      enabled: !_sending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quick scale + haptic on tap so sending feels tactile; the
                  // button's own onPressed still drives the actual send.
                  AnimatedPress(
                    onTap: _sending ? null : () => _send(),
                    scale: 0.9,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: IgnorePointer(
                        child: FilledButton(
                          onPressed: _sending ? null : () {},
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(borderRadius: VfRadius.brLg),
                          ),
                          child: const Icon(Icons.send, size: 20),
                        ),
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
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.onClear});
  final VoidCallback? onClear;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    return AppBar(
      toolbarHeight: 72,
      titleSpacing: 12,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: scheme.primary, borderRadius: VfRadius.brLg),
            child: Icon(Icons.restaurant_menu, color: scheme.onPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.chatTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: vf.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.chatSubtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: vf.mutedForeground),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: onClear, icon: const Icon(Icons.delete_sweep_outlined)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPickPrompt});
  final void Function(String prompt) onPickPrompt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    final prompts = [
      l10n.chatPrompt1,
      l10n.chatPrompt2,
      l10n.chatPrompt3,
      l10n.chatPrompt4,
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: scheme.primary, borderRadius: VfRadius.brXl),
            child: Icon(Icons.restaurant_menu, size: 36, color: scheme.onPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.chatEmptyHero,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.chatEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(color: vf.mutedForeground),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: prompts.map((p) => _PromptCard(text: p, onTap: () => onPickPrompt(p))).toList(),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: VfRadius.brLg,
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: VfRadius.brLg,
        splashColor: vf.zephir,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isAi = message.role == 'assistant' || message.role == 'model';
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            _Avatar(icon: Icons.restaurant_menu, bg: scheme.primary, fg: scheme.onPrimary),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAi ? vf.zephir : scheme.primary,
                borderRadius: VfRadius.brXl,
                border: Border.all(color: isAi ? scheme.outline : Colors.transparent),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isAi ? scheme.onSurface : scheme.onPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isAi) ...[
            const SizedBox(width: 8),
            _Avatar(icon: Icons.person, bg: vf.mistral, fg: scheme.onSurface),
          ],
        ],
      ),
    )
        // Newly mounted bubbles slide in from the speaker's side and fade up.
        // AI replies also pop in with a slight overshoot so an answer "lands"
        // with a bit of character; user bubbles get a gentler settle.
        .animate()
        .fadeIn(duration: 220.ms, curve: Curves.easeOut)
        .slideX(
          begin: isAi ? -0.06 : 0.06,
          end: 0,
          duration: 260.ms,
          curve: Curves.easeOutCubic,
        )
        .scaleXY(
          begin: isAi ? 0.92 : 0.97,
          end: 1,
          duration: isAi ? 320.ms : 240.ms,
          curve: isAi ? Curves.easeOutBack : Curves.easeOut,
        );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.icon, required this.bg, required this.fg});
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, borderRadius: VfRadius.brMd),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _Avatar(icon: Icons.restaurant_menu, bg: scheme.primary, fg: scheme.onPrimary),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: vf.zephir,
              borderRadius: VfRadius.brXl,
              border: Border.all(color: scheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDots(color: vf.mutedForeground),
                const SizedBox(width: 10),
                Text(l10n.chatThinking, style: TextStyle(color: vf.mutedForeground, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    )
        // Fade in like a regular bubble, then breathe gently so the "thinking"
        // state reads as alive rather than just a spinner sitting there.
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 220.ms, curve: Curves.easeOut)
        .then()
        .scaleXY(
          begin: 1,
          end: 1.02,
          duration: 1200.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Cute three-dot "typing" indicator. Each dot bounces up and brightens in
/// sequence so the row reads as the assistant actively composing a reply,
/// replacing the flat spinner.
class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});
  final Color color;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 14,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              // Stagger each dot a third of the cycle apart, then ease the
              // 0..1..0 wave so the bounce feels springy rather than linear.
              final phase = (_controller.value - i * 0.18) % 1.0;
              final wave = Curves.easeInOut.transform((1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0));
              return Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
                child: Transform.translate(
                  offset: Offset(0, -3 * wave),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.4 + 0.6 * wave),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
