import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../theme/apptheme.dart';
import '../utils/validators.dart';
import 'common.dart';
import 'role_picker.dart';

// Form for adding or editing a person. Pops the new TeamMember when saved.
class MemberFormSheet extends StatefulWidget {
  const MemberFormSheet({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.members,
    required this.roles,
    required this.onAddRole,
    this.member,
    this.initialEmail,
    this.subtitle,
    this.onSubmit,
    this.footer,
    this.busy = false,
    this.emailTakenMessage = 'Another member already uses this email.',
  });
  final String title;
  final String submitLabel;
  final List<TeamMember> members;
  final List<String> roles;
  final Future<void> Function(String name) onAddRole;
  final TeamMember? member;
  final String? initialEmail;
  final String? subtitle;
  // When set, the form sits inside a page (no sheet) and reports the member
  // here instead of popping.
  final ValueChanged<TeamMember>? onSubmit;
  final bool busy;
  // Extra widget shown under the button (used by the sign-up page).
  final Widget? footer;
  final String emailTakenMessage;

  @override
  State<MemberFormSheet> createState() => _MemberFormSheetState();
}

class _MemberFormSheetState extends State<MemberFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.member?.name ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.member?.email ?? widget.initialEmail ?? '',
  );
  late String _role = widget.member?.role ?? _defaultRole();

  String _defaultRole() =>
      widget.roles.contains('Team member') ? 'Team member' : widget.roles.last;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _name.text.trim();
    final initials = name
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    final member = TeamMember(
      id: widget.member?.id,
      name: name,
      role: _role,
      email: _email.text.trim().toLowerCase(),
      initials: initials,
    );
    final onSubmit = widget.onSubmit;
    if (onSubmit != null) {
      onSubmit(member);
    } else {
      Navigator.of(context).pop(member);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: TextStyle(color: context.scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 18),
          const FormLabel('Full name', required: true),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Jane Doe',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: Validators.personName,
          ),
          const SizedBox(height: 16),
          const FormLabel('Email address', required: true),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) => Validators.uniqueEmail(
              value,
              widget.members,
              exceptId: widget.member?.id,
              takenMessage: widget.emailTakenMessage,
            ),
          ),
          const SizedBox(height: 16),
          const FormLabel('Role', required: true),
          RolePicker(
            roles: widget.roles,
            selected: _role,
            onSelected: (role) => setState(() => _role = role),
            onAddRole: widget.onAddRole,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.busy ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: context.isDark
                  ? context.colors.violet
                  : AppTheme.ink,
              foregroundColor: context.isDark ? Colors.black : Colors.white,
            ),
            child: widget.busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
          if (widget.footer != null) ...[
            const SizedBox(height: 8),
            widget.footer!,
          ],
        ],
      ),
    );
    if (widget.onSubmit != null) return form;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(child: form),
    );
  }
}
