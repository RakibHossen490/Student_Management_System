enum UserRole { admin, student }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? studentId;
  final String? phone;
  final String? department;
  final String? semester;
  final UserRole role;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.studentId,
    this.phone,
    this.department,
    this.semester,
    required this.role,
    this.profileImageUrl,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      studentId: data['studentId'],
      phone: data['phone'],
      department: data['department'],
      semester: data['semester'],
      role: UserRole.values[data['role'] ?? 0],
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'phone': phone,
      'department': department,
      'semester': semester,
      'role': role.index,
      'profileImageUrl': profileImageUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? phone,
    String? department,
    String? semester,
    UserRole? role,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}