class UserProfile {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final int roleId;
  final String role;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.roleId,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isCustomer => !isAdmin;

  String get displayName {
    final full = '$firstname $lastname'.trim();
    if (full.isNotEmpty) return full;
    if (email.isNotEmpty) return email.split('@').first;
    return 'Customer';
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    String roleName = 'customer';
    if (map['roles'] != null && map['roles'] is Map) {
      roleName = (map['roles']['role'] as String?) ?? 'customer';
    } else if (map['role'] != null) {
      roleName = map['role'] as String;
    }

    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      firstname: map['firstname'] as String? ?? '',
      lastname: map['lastname'] as String? ?? '',
      roleId: (map['role_id'] as num?)?.toInt() ?? 1,
      role: roleName,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }
}

