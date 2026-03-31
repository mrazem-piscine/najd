class Volunteer {
  final String id;
  final String fullName;
  final String phone;
  final String city;
  final List<String> skills;
  final List<String> availability;
  final String? notes;
  final bool shareLocationAlways;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  Volunteer({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.skills,
    required this.availability,
    this.notes,
    this.shareLocationAlways = false,
    this.latitude,
    this.longitude,
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
      shareLocationAlways: json['share_location_always'] as bool? ?? false,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
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
      'share_location_always': shareLocationAlways,
      'latitude': latitude,
      'longitude': longitude,
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
    bool? shareLocationAlways,
    double? latitude,
    double? longitude,
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
      shareLocationAlways: shareLocationAlways ?? this.shareLocationAlways,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

const List<String> skillOptions = [
  'First Aid',
  'Maintenance',
  'Transportation',
  'Psychological Support',
  'Translation',
  'Aid Distribution',
];

const List<String> availabilityOptions = [
  'Morning',
  'Afternoon',
  'Evening',
  'Weekends',
  'Emergency Only',
];

/// List of cities in Israel and Palestine for city selection
const List<String> cities = [
  // Palestinian Cities
  'Gaza',
  'Gaza City',
  'Khan Yunis',
  'Rafah',
  'Jabalia',
  'Deir al-Balah',
  'Beit Hanoun',
  'Beit Lahia',
  'Nuseirat',
  'Ramallah',
  'Nablus',
  'Hebron',
  'Bethlehem',
  'Jenin',
  'Tulkarm',
  'Qalqilya',
  'Jericho',
  'Salfit',
  'Tubas',
  // Israeli Cities
  'Jerusalem',
  'Tel Aviv',
  'Haifa',
  'Rishon LeZion',
  'Petah Tikva',
  'Ashdod',
  'Netanya',
  'Beersheba',
  'Holon',
  'Bnei Brak',
  'Ramat Gan',
  'Ashkelon',
  'Rehovot',
  'Bat Yam',
  'Herzliya',
  'Kfar Saba',
  'Hadera',
  'Modiin',
  'Nazareth',
  'Lod',
  'Ramleh',
  'Acre',
  'Eilat',
  'Tiberias',
  'Safed',
];
