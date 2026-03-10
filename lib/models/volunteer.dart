class Volunteer {
  final String id;
  final String fullName;
  final String phone;
  final String city;
  final List<String> skills;
  final List<String> availability;
  final String? notes;
  final DateTime createdAt;

  Volunteer({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.skills,
    required this.availability,
    this.notes,
    required this.createdAt,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      skills: json['skills'] != null
          ? List<String>.from(json['skills'] as List)
          : [],
      availability: json['availability'] != null
          ? List<String>.from(json['availability'] as List)
          : [],
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
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
    String? phone,
    String? city,
    List<String>? skills,
    List<String>? availability,
    String? notes,
    DateTime? createdAt,
  }) {
    return Volunteer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      notes: notes ?? this.notes,
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
