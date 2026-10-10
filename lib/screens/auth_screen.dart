import 'package:flutter/material.dart';

import '../models/team_member.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _role = _roles.last;
  bool _creating = false;
  bool _saving = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  TeamMember? _findMember(String email) {
    for (final member in widget.members) {
      if (member.email.trim().toLowerCase() == email) return member;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim().toLowerCase();

    if (!_creating) {
      final member = _findMember(email);
      if (member != null) {
        widget.onSignIn(member);
      } else {
        setState(() => _creating = true);
      }
      return;
    }

    setState(() => _saving = true);
    await widget.onRegister(_nameController.text.trim(), email, _role);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.track_changes_rounded,
                      size: 48,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to taskMS',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _creating
                          ? 'No account was found for this email. '
                                'Create one to continue.'
                          : 'Enter your email to sign in.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (_) {
                        if (_creating) setState(() => _creating = false);
                      },
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Enter your email';
                        if (!text.contains('@') || !text.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    if (_creating) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 2) {
                            return 'Enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: [
                          for (final role in _roles)
                            DropdownMenuItem(value: role, child: Text(role)),
                        ],
                        onChanged: (value) =>
                            setState(() => _role = value ?? _role),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: Text(_creating ? 'Create account' : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
