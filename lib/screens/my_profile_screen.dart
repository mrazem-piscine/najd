import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../models/volunteer.dart';
import '../services/user_profile_service.dart';
import '../widgets/animations.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final ImagePicker _picker = ImagePicker();
  Volunteer? _profile;
  bool _loading = true;
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final v = await _profileService.getProfileAsVolunteer();
      if (mounted) setState(() => _profile = v);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    // Photo upload is only available on mobile apps (iOS/Android)
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo upload is available on the mobile app'),
          backgroundColor: AppTheme.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppTheme.primary),
                ),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (photo != null && mounted) {
                      setState(() => _profileImage = photo);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Camera not available: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: AppTheme.secondary),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null && mounted) {
                      setState(() => _profileImage = image);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open gallery: $e')),
                      );
                    }
                  }
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: AppTheme.error),
                  ),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _profileImage = null);
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_profile == null ||
        (_profile!.fullName.isEmpty && _profile!.phone.isEmpty)) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Profile Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your profile to get started',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.buttonShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _MyProfileFormScreen()),
                      ).then((_) => _load()),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Create Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final v = _profile!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient header with avatar
            SlideInAnimation(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Edit button
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const _MyProfileFormScreen()),
                          ).then((_) => _load()),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                    // Avatar with photo option
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.accent,
                                backgroundImage: _profileImage != null
                                    ? (kIsWeb
                                        ? NetworkImage(_profileImage!.path)
                                        : FileImage(File(_profileImage!.path)) as ImageProvider)
                                    : null,
                                child: _profileImage == null
                                    ? Text(
                                        v.fullName.isNotEmpty
                                            ? v.fullName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          // Camera icon overlay
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      v.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          v.city,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Contact info card
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: _ProfileSection(
                      title: 'Contact Information',
                      icon: Icons.contact_phone,
                      children: [
                        _ProfileInfoRow(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: v.phone,
                        ),
                        _ProfileInfoRow(
                          icon: Icons.location_city,
                          label: 'City',
                          value: v.city,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skills card
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: _ProfileSection(
                      title: 'Skills',
                      icon: Icons.work_outline,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: v.skills.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.secondaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Availability card
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: _ProfileSection(
                      title: 'Availability',
                      icon: Icons.schedule,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: v.availability.map((a) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.success.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 14, color: AppTheme.success),
                                  const SizedBox(width: 6),
                                  Text(
                                    a,
                                    style: const TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  if (v.notes != null && v.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: _ProfileSection(
                        title: 'Notes',
                        icon: Icons.note,
                        children: [
                          Text(
                            v.notes!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Location sharing status
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 500),
                    child: _ProfileSection(
                      title: 'Location Settings',
                      icon: Icons.location_on,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: v.shareLocationAlways
                                    ? AppTheme.success.withOpacity(0.1)
                                    : AppTheme.textLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: v.shareLocationAlways
                                      ? AppTheme.success.withOpacity(0.3)
                                      : AppTheme.textLight.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    v.shareLocationAlways
                                        ? Icons.location_on
                                        : Icons.location_off,
                                    size: 14,
                                    color: v.shareLocationAlways
                                        ? AppTheme.success
                                        : AppTheme.textLight,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    v.shareLocationAlways
                                        ? 'Location Sharing Active'
                                        : 'Location Sharing Off',
                                    style: TextStyle(
                                      color: v.shareLocationAlways
                                          ? AppTheme.success
                                          : AppTheme.textLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textLight),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyProfileFormScreen extends StatefulWidget {
  const _MyProfileFormScreen();

  @override
  State<_MyProfileFormScreen> createState() => _MyProfileFormScreenState();
}

class _MyProfileFormScreenState extends State<_MyProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserProfileService _profileService = UserProfileService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _citySearchController = TextEditingController();
  String? _selectedCity;
  List<String> _filteredCities = [];
  bool _showCityDropdown = false;
  List<String> _skills = [];
  List<String> _availability = [];
  bool _shareLocationAlways = false;
  double? _latitude;
  double? _longitude;
  bool _loading = false;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final v = await _profileService.getProfileAsVolunteer();
    if (v != null && mounted) {
      _nameController.text = v.fullName;
      _phoneController.text = v.phone;
      _selectedCity = v.city.isNotEmpty ? v.city : null;
      _citySearchController.text = v.city;
      _notesController.text = v.notes ?? '';
      _skills = List.from(v.skills);
      _availability = List.from(v.availability);
      _shareLocationAlways = v.shareLocationAlways;
      _latitude = v.latitude;
      _longitude = v.longitude;
      setState(() {});
    }
  }

  void _filterCities(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCities = [];
        _showCityDropdown = false;
      });
      return;
    }
    final filtered = cities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredCities = filtered;
      _showCityDropdown = filtered.isNotEmpty;
    });
  }

  void _selectCity(String city) {
    setState(() {
      _selectedCity = city;
      _citySearchController.text = city;
      _showCityDropdown = false;
      _filteredCities = [];
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Location services are disabled'),
            backgroundColor: AppTheme.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Location permission denied'),
              backgroundColor: AppTheme.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Location permissions are permanently denied'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Location updated successfully'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _citySearchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select a valid city from the list'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    if (_skills.isEmpty || _availability.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Select at least one skill and availability'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      await _profileService.upsertProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _selectedCity!,
        skills: _skills,
        availability: _availability,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        shareLocationAlways: _shareLocationAlways,
        latitude: _latitude,
        longitude: _longitude,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Profile saved successfully'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal info section
              _FormSection(
                title: 'Personal Information',
                children: [
                  _ModernTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _ModernTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  // City search field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _citySearchController,
                        onChanged: _filterCities,
                        onTap: () {
                          if (_citySearchController.text.isNotEmpty) {
                            _filterCities(_citySearchController.text);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'City',
                          prefixIcon: const Icon(Icons.location_city, color: AppTheme.primary),
                          suffixIcon: _selectedCity != null
                              ? const Icon(Icons.check_circle, color: AppTheme.success)
                              : null,
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          hintText: 'Search for your city...',
                        ),
                        validator: (v) {
                          if (_selectedCity == null || _selectedCity!.isEmpty) {
                            return 'Please select a city from the list';
                          }
                          return null;
                        },
                      ),
                      if (_showCityDropdown && _filteredCities.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = _filteredCities[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: AppTheme.primary),
                                title: Text(city),
                                onTap: () => _selectCity(city),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Skills section
              _FormSection(
                title: 'Skills',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skillOptions.map((s) {
                      final selected = _skills.contains(s);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _skills.remove(s);
                            } else {
                              _skills.add(s);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient:
                                selected ? AppTheme.primaryGradient : null,
                            color: selected ? null : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: selected
                                ? null
                                : Border.all(color: AppTheme.surfaceLight),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Availability section
              _FormSection(
                title: 'Availability',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availabilityOptions.map((a) {
                      final selected = _availability.contains(a);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _availability.remove(a);
                            } else {
                              _availability.add(a);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient:
                                selected ? AppTheme.successGradient : null,
                            color: selected ? null : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: selected
                                ? null
                                : Border.all(color: AppTheme.surfaceLight),
                          ),
                          child: Text(
                            a,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notes section
              _FormSection(
                title: 'Additional Notes',
                children: [
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Any additional information...',
                      hintStyle: const TextStyle(color: AppTheme.textLight),
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Location sharing section
              _FormSection(
                title: 'Location Settings',
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _shareLocationAlways
                                    ? AppTheme.success.withOpacity(0.1)
                                    : AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: _shareLocationAlways
                                    ? AppTheme.success
                                    : AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Share Location Always',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Allow the system to track your location for better task matching',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _shareLocationAlways,
                              onChanged: (value) {
                                setState(() => _shareLocationAlways = value);
                                if (value && _latitude == null) {
                                  _getCurrentLocation();
                                }
                              },
                              activeColor: AppTheme.success,
                            ),
                          ],
                        ),
                        if (_shareLocationAlways) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _latitude != null && _longitude != null
                                          ? 'Location: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                                          : 'Location not set',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _gettingLocation ? null : _getCurrentLocation,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: _gettingLocation
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.my_location,
                                                    color: Colors.white, size: 18),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Update',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save button
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _loading ? null : _submit,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.error, width: 2),
        ),
      ),
    );
  }
}
