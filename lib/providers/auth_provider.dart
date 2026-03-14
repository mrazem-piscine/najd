import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../services/account_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final AccountService _accountService = AccountService();

  User? _user;
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isProfileLoading = false;
  String? _error;

  User? get user => _user;
  UserProfile? get profile => _profile;
  UserRole get role => _profile?.role ?? UserRole.volunteer;
  bool get isLoading => _isLoading;
  bool get isProfileLoading => _isProfileLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
    _authService.authStateChanges.listen(_onAuthStateChange);
  }

  void _setUser(User? user) {
    _user = user;
    if (user == null) {
      _profile = null;
    }
  }

  Future<void> _init() async {
    _setUser(await _authService.getSession());
    if (_user != null) {
      await _loadProfile();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    _isProfileLoading = true;
    notifyListeners();
    try {
      _profile = await _accountService.getOrCreateProfile(
        email: _user?.email,
      );
    } catch (_) {
      // keep existing profile/null on error
    }
    _isProfileLoading = false;
    notifyListeners();
  }

  void _onAuthStateChange(AuthState data) {
    _setUser(data.session?.user);
    if (_user != null) {
      _loadProfile();
    } else {
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      _setUser(_authService.currentUser);
      await _loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUp(email: email, password: password);
      _setUser(_authService.currentUser);
      await _loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _setUser(null);
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
