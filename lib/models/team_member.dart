class TeamMember {
  const TeamMember({
    this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.initials,
  });

  final int? id;
  final String name;
  final String role;
  final String email;
  final String initials;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'role': role,
    'email': email,
    'initials': initials,
  };

  factory TeamMember.fromMap(Map<String, Object?> map) {
    final name = map['name'] as String;
    return TeamMember(
      id: map['id'] as int?,
      name: name,
      role: map['role'] as String? ?? 'Team member',
      email: map['email'] as String? ?? '',
      initials:
          map['initials'] as String? ??
          name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0])
              .join()
              .toUpperCase(),
    );
  }
}
