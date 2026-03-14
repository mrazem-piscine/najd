import 'user_role.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final List<String> skills;
  final List<String> availability;
  final String? notes;
  final UserRole role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.skills,
    required this.availability,
    required this.notes,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills'] as List) : const [],
      availability: json['availability'] != null ? List<String>.from(json['availability'] as List) : const [],
      notes: json['notes'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'city': city,
      'skills': skills,
      'availability': availability,
      'notes': notes,
      'role': role.value,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? city,
    List<String>? skills,
    List<String>? availability,
    String? notes,
    UserRole? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      notes: notes ?? this.notes,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
