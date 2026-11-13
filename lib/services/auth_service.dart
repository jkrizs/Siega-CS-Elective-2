import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show supabase;

class AccountInfo {
  const AccountInfo({required this.displayName, this.email, this.provider});

  final String displayName;
  final String? email;
  final String? provider;
}

abstract class AuthService {
  AccountInfo? get currentAccount;

  Stream<void> get authChanges;

  Future<void> signInWithEmail(String email, String password);

  Future<bool> registerWithEmail(String email, String password);

  Future<void> signInWithGitHub();

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  String? get _webRedirect => kIsWeb ? Uri.base.origin : null;

  @override
  AccountInfo? get currentAccount {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final meta = user.userMetadata ?? const {};
    final name = meta['user_name'] ?? meta['full_name'] ?? meta['name'];
    return AccountInfo(
      displayName: name is String && name.isNotEmpty
          ? name
          : (user.email ?? 'Customer'),
      email: user.email,
      provider: user.appMetadata['provider'] as String?,
    );
  }

  @override
  Stream<void> get authChanges => supabase.auth.onAuthStateChange;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> registerWithEmail(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _webRedirect,
    );
    return response.session != null;
  }

  @override
  Future<void> signInWithGitHub() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: _webRedirect,
    );
  }

  @override
  Future<void> signOut() => supabase.auth.signOut();
}
