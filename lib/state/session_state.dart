import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class SessionState extends ChangeNotifier {
  SessionState({AuthService? service})
      : _service = service ?? SupabaseAuthService() {
    _authSubscription = _service.authChanges.listen((_) => notifyListeners());
  }

  final AuthService _service;
  late final StreamSubscription<void> _authSubscription;

  bool _loading = false;
  String? _error;
  String? _info;

  AccountInfo? get account => _service.currentAccount;
  bool get isLoggedIn => account != null;
  bool get loading => _loading;
  String? get error => _error;
  String? get info => _info;

  Future<void> login(String email, String password) =>
      _guard(() => _service.signInWithEmail(email, password));

  Future<void> register(String email, String password) => _guard(() async {
        final loggedIn = await _service.registerWithEmail(email, password);
        if (!loggedIn) {
          _info = 'We sent a confirmation link to $email. '
              'Open it, then log in here.';
        }
      });

  Future<void> loginWithGitHub() => _guard(_service.signInWithGitHub);

  Future<void> logout() => _guard(_service.signOut);

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
    } catch (_) {
      _error = 'Something went wrong. Check your connection and try again.';
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
