import '../models/team_member.dart';

// Each validator returns an error message, or null when the value is fine.
class Validators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static final _namePattern = RegExp(r"^[\p{L}][\p{L} .'-]*$", unicode: true);

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter an email address.';
    if (text.length > 100) return 'Email must be under 100 characters.';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address.';
    return null;
  }

  // Used when adding or editing a member so two people never share an email.
  static String? uniqueEmail(
    String? value,
    List<TeamMember> members, {
    int? exceptId,
    String takenMessage = 'Another member already uses this email.',
  }) {
    final basic = email(value);
    if (basic != null) return basic;
    final typed = value!.trim().toLowerCase();
    for (final member in members) {
      if (member.id != exceptId && member.email.trim().toLowerCase() == typed) {
        return takenMessage;
      }
    }
    return null;
  }

  static String? personName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your full name.';
    if (text.length < 2) return 'Name must be at least 2 characters.';
    if (text.length > 40) return 'Name must be under 40 characters.';
    if (!_namePattern.hasMatch(text)) {
      return 'Use letters, spaces, . - and apostrophes only.';
    }
    return null;
  }

  static String? taskTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a task title.';
    if (text.length < 3) return 'Use at least 3 characters.';
    if (text.length > 80) return 'Keep the title under 80 characters.';
    if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(text)) {
      return 'Title needs letters or numbers.';
    }
    return null;
  }

  static String? description(String? value) {
    if ((value?.trim().length ?? 0) > 500) {
      return 'Keep the description under 500 characters.';
    }
    return null;
  }

  static String? required(Object? value, String message) =>
      value == null || (value is String && value.trim().isEmpty)
      ? message
      : null;

  // A new task cannot start with a deadline that has already passed.
  static String? deadline(DateTime? value, {DateTime? now}) {
    if (value == null) return 'Choose a deadline.';
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    if (value.isBefore(today)) return 'Deadline cannot be in the past.';
    return null;
  }

  // A new role must be a short label that is not already in the list.
  static String? roleName(String? value, List<String> existing) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a role name.';
    if (text.length < 2) return 'Role must be at least 2 characters.';
    if (text.length > 30) return 'Role must be under 30 characters.';
    if (!RegExp(
      r"^[\p{L}\p{N}][\p{L}\p{N} &/.'-]*$",
      unicode: true,
    ).hasMatch(text)) {
      return 'Use letters, numbers and spaces only.';
    }
    final lower = text.toLowerCase();
    if (existing.any((role) => role.toLowerCase() == lower)) {
      return 'This role already exists.';
    }
    return null;
  }
}
