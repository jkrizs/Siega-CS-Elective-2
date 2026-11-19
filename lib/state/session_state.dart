import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../utils/error_messages.dart';

class SessionState extends ChangeNotifier {
  SessionState({AuthService? service})
      : _service = service ?? SupabaseAuthService() {
    _authSubscription = _service.authChanges.listen((_) => _handleAuthChange());
    _loadProfile();
  }

  final AuthService _service;
  late final StreamSubscription<AuthState> _authSubscription;

  UserProfile? _profile;
  bool _loading = false;
  String? _error;
  String? _info;

  User? get user => _service.currentUser;
  UserProfile? get profile => _profile;
  bool get isLoggedIn => user != null;
  bool get isAdmin => _profile?.isAdmin ?? false;
  bool get isCustomer => !isAdmin;
  bool get loading => _loading;
  String? get error => _error;
  String? get info => _info;

  Future<void> _handleAuthChange() async {
    await _loadProfile();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    if (user != null) {
      _profile = await _service.fetchUserProfile();
    } else {
      _profile = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) => _guard(() async {
        await _service.signInWithEmail(email, password);
        await _loadProfile();
      });

  Future<void> register(
    String email,
    String password, {
    String? firstname,
    String? lastname,
  }) =>
      _guard(() async {
        final loggedIn = await _service.registerWithEmail(
          email,
          password,
          firstname: firstname,
          lastname: lastname,
        );
        if (!loggedIn) {
          _info = 'We sent a confirmation link to $email. Open it, then log in here.';
        } else {
          await _loadProfile();
        }
      });

  Future<void> loginWithGoogle() => _guard(() async {
        await _service.signInWithGoogle();
        await _loadProfile();
      });

  Future<void> logout() => _guard(() async {
        await _service.signOut();
        _profile = null;
      });

  void dismissMessages() {
    _error = null;
    _info = null;
    notifyListeners();
  }

  Future<void> _guard(Future<void> Function() task) async {
    _loading = true;
    _error = null;
    _info = null;
    notifyListeners();
    try {
      await task();
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
