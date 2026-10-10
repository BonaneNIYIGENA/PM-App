import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';

enum _Step { email, signingIn, create }

const _roles = [
  'Project lead',
  'Flutter developer',
  'UI designer',
  'QA engineer',
  'Team member',
];

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.members,
    required this.onSignIn,
    required this.onRegister,
  });

  final List<TeamMember> members;
  final ValueChanged<TeamMember> onSignIn;
  final Future<void> Function(String name, String email, String role)
  onRegister;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailForm = GlobalKey<FormState>();
  final _createForm = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _name = TextEditingController();
  _Step _step = _Step.email;
  TeamMember? _match;
  String _role = _roles.last;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_emailForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final email = _email.text.trim().toLowerCase();
    TeamMember? found;
    for (final member in widget.members) {
      if (member.email.trim().toLowerCase() == email) {
        found = member;
        break;
      }
    }
    if (found == null) {
      setState(() => _step = _Step.create);
      return;
    }
    setState(() {
      _match = found;
      _step = _Step.signingIn;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted || _step != _Step.signingIn) return;
    widget.onSignIn(found);
  }

  Future<void> _create() async {
    if (!_createForm.currentState!.validate()) return;
    setState(() => _busy = true);
    await widget.onRegister(_name.text.trim(), _email.text.trim(), _role);
    if (mounted) setState(() => _busy = false);
  }

  void _backToEmail() => setState(() {
    _step = _Step.email;
    _match = null;
  });

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final gradient = dark
        ? const [Color(0xFF000000), Color(0xFF1A1140)]
        : const [Color(0xFF5B3BEA), Color(0xFF9A7BFF)];
    return Scaffold(
      backgroundColor: dark ? Colors.black : const Color(0xFF5B3BEA),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        _Hero(compact: _step != _Step.email),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              24,
                              28,
                              24,
                              24 + MediaQuery.of(context).padding.bottom,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF0C0C0E)
                                  : context.scheme.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(36),
                              ),
                              border: dark
                                  ? Border(
                                      top: BorderSide(
                                        color: context.scheme.outlineVariant,
                                      ),
                                    )
                                  : null,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOutCubic,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween(
                                        begin: const Offset(.06, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                              child: SingleChildScrollView(
                                key: ValueKey(_step),
                                physics: const NeverScrollableScrollPhysics(),
                                child: switch (_step) {
                                  _Step.email => _emailStep(context),
                                  _Step.signingIn => _signingInStep(context),
                                  _Step.create => _createStep(context),
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailStep(BuildContext context) => Column(
    key: const ValueKey('email'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Welcome to taskMS',
        style: context.text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Enter your email to sign in. New here? We’ll set up your account in a moment.',
        style: TextStyle(color: context.scheme.onSurfaceVariant, height: 1.4),
      ),
      const SizedBox(height: 22),
      Form(
        key: _emailForm,
        child: TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.go,
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
          validator: (value) =>
              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value?.trim() ?? '')
              ? null
              : 'Enter a valid email address.',
          onFieldSubmitted: (_) => _continue(),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _continue,
          icon: const Icon(Icons.arrow_forward_rounded),
          iconAlignment: IconAlignment.end,
          label: const Text('Continue'),
        ),
      ),
      const SizedBox(height: 18),
      Center(
        child: Text(
          'Accounts are stored on this device only.',
          style: TextStyle(
            color: context.scheme.onSurfaceVariant,
            fontSize: 12.5,
          ),
        ),
      ),
    ],
  );

  Widget _signingInStep(BuildContext context) {
    final member = _match!;
    return Column(
      key: const ValueKey('signing'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: .6, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (_, value, child) =>
              Transform.scale(scale: value, child: child),
          child: MemberAvatar(member: member, radius: 38),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome back, ${member.name.split(' ').first}!',
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          member.role,
          style: TextStyle(color: context.scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: _backToEmail,
          child: const Text('Not you? Use a different email'),
        ),
      ],
    );
  }

  Widget _createStep(BuildContext context) => Form(
    key: _createForm,
    child: Column(
      key: const ValueKey('create'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Pressable(
              borderRadius: 12,
              onTap: _backToEmail,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.scheme.outlineVariant),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Create your account',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'We couldn’t find ${_email.text.trim()}. Add your details to get started.',
          style: TextStyle(color: context.scheme.onSurfaceVariant, height: 1.4),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (value) =>
              (value?.trim().length ?? 0) < 2 ? 'Enter your name.' : null,
          onFieldSubmitted: (_) => _create(),
        ),
        const SizedBox(height: 16),
        Text(
          'Your role',
          style: context.text.labelLarge?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final role in _roles)
              _RoleChip(
                label: role,
                selected: _role == role,
                onTap: () => setState(() => _role = role),
              ),
          ],
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : _create,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Create account'),
          ),
        ),
      ],
    ),
  );
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;
    return Pressable(
      borderRadius: 20,
      scale: .94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? context.soft(primary, alpha: .18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primary : context.scheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? primary : context.scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatefulWidget {
  const _Hero({required this.compact});
  final bool compact;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 22, 28, 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: .3)),
              ),
              child: const Icon(Icons.task_alt_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'taskMS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: widget.compact
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 26),
                    const Text(
                      'Plan the work.\nBeat the deadline.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 112,
                      child: AnimatedBuilder(
                        animation: _float,
                        builder: (context, _) {
                          final t = Curves.easeInOut.transform(_float.value);
                          return Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 8 - 8 * t,
                                child: const _MiniCard(
                                  icon: Icons.check_circle_rounded,
                                  title: 'Design onboarding',
                                  subtitle: 'Due tomorrow',
                                  width: 196,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 40 + 8 * t,
                                child: const _MiniCard(
                                  icon: Icons.bolt_rounded,
                                  title: '82% done',
                                  subtitle: 'Sprint delivery',
                                  width: 150,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    ),
  );
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.width,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .96),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .2),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF6C4CF1)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF15141C),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5D5A70),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}