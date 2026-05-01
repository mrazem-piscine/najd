class Volunteer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final List<String> skills;
  final List<String> availability;
  final String? notes;
  /// From `profiles.role` when listing via coordinator RPC (admin/support).
  final String? appRole;
  final DateTime createdAt;

  Volunteer({
    required this.id,
    required this.fullName,
    this.email = '',
    required this.phone,
    required this.city,
    required this.skills,
    required this.availability,
    this.notes,
    this.appRole,
    required this.createdAt,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      skills: json['skills'] != null
          ? List<String>.from(json['skills'] as List)
          : [],
      availability: json['availability'] != null
          ? List<String>.from(json['availability'] as List)
          : [],
      notes: json['notes'] as String?,
      appRole: json['role'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  Volunteer copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? city,
    List<String>? skills,
    List<String>? availability,
    String? notes,
    String? appRole,
    DateTime? createdAt,
  }) {
    return Volunteer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      notes: notes ?? this.notes,
      appRole: appRole ?? this.appRole,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

const List<String> skillOptions = [
  'Medical',
  'Logistics',
  'Driving',
  'Translation',
  'Media',
  'Technical',
  'General Help',
];

const List<String> availabilityOptions = [
  'Morning',
  'Afternoon',
  'Evening',
  'Weekends',
  'Emergency Only',
];
