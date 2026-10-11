import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../theme/apptheme.dart';
import '../utils/validators.dart';
import '../widgets/common.dart';
import '../widgets/member_form_sheet.dart';
import '../widgets/taskms_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.members,
    required this.roles,
    required this.onAddRole,
    required this.onSignIn,
    required this.onRegister,
  });

  final List<TeamMember> members;
  final List<String> roles;
  final Future<void> Function(String name) onAddRole;
  final ValueChanged<TeamMember> onSignIn;
  final Future<void> Function(String name, String email, String role)
  onRegister;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _notFound = false;
  bool _creating = false;
  bool _fromUnknownEmail = false;
  bool _saving = false;
  String? _prefillEmail;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _createLink.dispose();
    _email.dispose();
    super.dispose();
  }

  String get _typed => _email.text.trim().toLowerCase();

  bool get _emailValid => Validators.email(_typed) == null;

  TeamMember? _findMember() {
    for (final member in widget.members) {
      if (member.email.trim().toLowerCase() == _typed) return member;
    }
    return null;
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final member = _findMember();
    if (member == null) {
      // Unknown email: only tell the user. They choose to create an account.
      setState(() => _notFound = true);
      return;
    }
    widget.onSignIn(member);
  }

  // Swaps the sign-in form for the create-account form, keeping the email.
  void _startCreating({bool unknownEmail = false}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _creating = true;
      _fromUnknownEmail = unknownEmail;
      _prefillEmail = _emailValid ? _email.text.trim() : null;
    });
  }

  void _backToSignIn() => setState(() => _creating = false);

  // The "click here" text in the not-registered message.
  late final TapGestureRecognizer _createLink = TapGestureRecognizer()
    ..onTap = () => _startCreating(unknownEmail: true);

  // The shell saves the member and signs them in right away.
  Future<void> _register(TeamMember created) async {
    setState(() => _saving = true);
    await widget.onRegister(created.name, created.email, created.role);
    if (mounted) setState(() => _saving = false);
  }

  Widget _signInView(
    BuildContext context, {
    required Color danger,
    required Color orange,
    required bool dark,
    required OutlineInputBorder redBorder,
  }) {
    final scheme = context.scheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Heading(),
          const SizedBox(height: 22),
          const FormLabel('Email address'),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.go,
            onChanged: (_) {
              if (_notFound) {
                setState(() => _notFound = false);
              }
            },
            onFieldSubmitted: (_) => _signIn(),
            decoration: InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              suffixIcon: _notFound
                  ? Icon(Icons.error_rounded, color: danger)
                  : null,
              enabledBorder: _notFound ? redBorder : null,
              focusedBorder: _notFound ? redBorder : null,
            ),
            validator: Validators.email,
          ),
          if (_notFound) ...[
            const SizedBox(height: 8),
            Text(
              'This email is not registered.',
              style: TextStyle(
                color: danger,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                style: TextStyle(color: danger, fontSize: 12.5),
                children: [
                  const TextSpan(text: 'New to taskMS? '),
                  TextSpan(
                    text: 'Click here to create an account.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _createLink,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _saving ? null : _signIn,
            iconAlignment: IconAlignment.end,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_forward_rounded, size: 20),
            label: Text(_saving ? 'Creating account' : 'Sign in'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: dark ? orange : AppTheme.ink,
              foregroundColor: dark ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'New to taskMS?',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 22),
          OutlinedButton(
            onPressed: _startCreating,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              foregroundColor: orange,
              side: BorderSide(color: orange, width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }

  Widget _createView(BuildContext context) => MemberFormSheet(
    key: const ValueKey('create'),
    title: 'Create your account',
    submitLabel: 'Create account',
    subtitle: _fromUnknownEmail
        ? 'This email is not registered yet. Create your account to continue.'
        : 'Tell us who you are so tasks can be assigned to you.',
    members: widget.members,
    roles: widget.roles,
    onAddRole: widget.onAddRole,
    initialEmail: _prefillEmail,
    emailTakenMessage: 'An account with this email already exists.',
    busy: _saving,
    onSubmit: _register,
    footer: TextButton(
      onPressed: _saving ? null : _backToSignIn,
      child: const Text('Already have an account? Sign in'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final orange = context.colors.violet;
    final danger = context.colors.danger;
    final height = MediaQuery.of(context).size.height;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final redBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: danger, width: 1.5),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(child: _HeroBackground(dark: dark)),
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: keyboardOpen
                    ? 76
                    : _creating
                    ? 170
                    : (height * .36).clamp(210.0, 320.0),
                width: double.infinity,
                child: ClipRect(
                  child: keyboardOpen
                      ? _CompactHeader(dark: dark)
                      : _Hero(dark: dark, compact: _creating),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF16161A) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? .5 : .08),
                        blurRadius: 30,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _creating
                              ? _createView(context)
                              : _signInView(
                                  context,
                                  danger: danger,
                                  orange: orange,
                                  dark: dark,
                                  redBorder: redBorder,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Welcome back',
        style: context.text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Sign in with your email to continue.',
        style: TextStyle(color: context.scheme.onSurfaceVariant),
      ),
    ],
  );
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final glow = context.colors.violet;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF000000), Color(0xFF2A170A)]
              : const [Color(0xFFFFF4E8), Color(0xFFFFB873)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glow.withValues(alpha: dark ? .5 : .35),
                    glow.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -90,
            top: 90,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glow.withValues(alpha: dark ? .22 : .25),
                    glow.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.dark, this.compact = false});
  final bool dark;
  final bool compact;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Center(
        // Scales the logo block down on short screens instead of overflowing.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TaskMsLogo(size: compact ? 72 : 104),
              const SizedBox(height: 4),
              Text(
                'taskMS',
                style: TextStyle(
                  color: dark ? Colors.white : AppTheme.ink,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text(
                  'Small teams. Big progress.',
                  style: TextStyle(
                    color: dark
                        ? Colors.white70
                        : AppTheme.ink.withValues(alpha: .7),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

// Small header used while the keyboard is open, so the form keeps its space.
class _CompactHeader extends StatelessWidget {
  const _CompactHeader({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
      child: Row(
        children: [
          const TaskMsLogo(size: 44),
          const SizedBox(width: 6),
          Text(
            'taskMS',
            style: TextStyle(
              color: dark ? Colors.white : AppTheme.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -.3,
            ),
          ),
        ],
      ),
    ),
  );
}
