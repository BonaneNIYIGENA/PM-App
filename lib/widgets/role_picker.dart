import 'package:flutter/material.dart';

import '../theme/apptheme.dart';
import '../utils/validators.dart';
import 'common.dart';

// Role chips plus an "Add role" chip that turns into a small input.
class RolePicker extends StatefulWidget {
  const RolePicker({
    super.key,
    required this.roles,
    required this.selected,
    required this.onSelected,
    required this.onAddRole,
  });
  final List<String> roles;
  final String selected;
  final ValueChanged<String> onSelected;
  final Future<void> Function(String name) onAddRole;

  @override
  State<RolePicker> createState() => _RolePickerState();
}

class _RolePickerState extends State<RolePicker> {
  final _controller = TextEditingController();
  late List<String> _roles = [...widget.roles];
  bool _adding = false;
  String? _error;

  @override
  void didUpdateWidget(RolePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final role in widget.roles) {
      if (!_roles.contains(role)) _roles.add(role);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = Validators.roleName(_controller.text, _roles);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final name = _controller.text.trim();
    await widget.onAddRole(name);
    if (!mounted) return;
    setState(() {
      _roles = [..._roles, name];
      _adding = false;
      _error = null;
      _controller.clear();
    });
    widget.onSelected(name);
  }

  @override
  Widget build(BuildContext context) {
    final shown = [
      ..._roles,
      if (!_roles.contains(widget.selected)) widget.selected,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final role in shown)
          RoleChoiceChip(
            role: role,
            selected: widget.selected == role,
            onTap: () => widget.onSelected(role),
          ),
        if (_adding)
          SizedBox(
            width: 240,
            child: TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'New role',
                errorText: _error,
                isDense: true,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Save role',
                      onPressed: _submit,
                      icon: const Icon(Icons.check_rounded),
                    ),
                    IconButton(
                      tooltip: 'Cancel',
                      onPressed: () => setState(() {
                        _adding = false;
                        _error = null;
                        _controller.clear();
                      }),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Pressable(
            onTap: () => setState(() => _adding = true),
            borderRadius: 14,
            scale: .95,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.scheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: context.scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add role',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// A selectable role pill.
class RoleChoiceChip extends StatelessWidget {
  const RoleChoiceChip({
    super.key,
    required this.role,
    required this.selected,
    required this.onTap,
  });
  final String role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.violet;
    return Pressable(
      onTap: onTap,
      borderRadius: 14,
      scale: .95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.soft(accent, alpha: .16) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : context.scheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          role,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? accent : context.scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
