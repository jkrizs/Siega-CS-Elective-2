import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show supabase;
import '../models/user_profile.dart';

abstract class AuthService {
  User? get currentUser;
  Stream<AuthState> get authChanges;

  Future<void> signInWithEmail(String email, String password);

  Future<bool> registerWithEmail(
    String email,
    String password, {
    String? firstname,
    String? lastname,
  });

  Future<void> signInWithGoogle();

  Future<UserProfile?> fetchUserProfile();

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  String? get _webRedirect => kIsWeb ? Uri.base.origin : null;

  @override
  User? get currentUser => supabase.auth.currentUser;

  @override
  Stream<AuthState> get authChanges => supabase.auth.onAuthStateChange;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> registerWithEmail(
    String email,
    String password, {
    String? firstname,
    String? lastname,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _webRedirect,
      data: {
        if (firstname != null && firstname.isNotEmpty) 'firstname': firstname,
        if (lastname != null && lastname.isNotEmpty) 'lastname': lastname,
      },
    );
    return response.session != null;
  }

  @override
  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _webRedirect,
    );
  }

  @override
  Future<UserProfile?> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await supabase
          .from('profiles')
          .select('*, roles(role)')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Fallback if profile trigger is delayed
        return UserProfile(
          id: user.id,
          email: user.email ?? '',
          firstname: (user.userMetadata?['firstname'] as String?) ?? '',
          lastname: (user.userMetadata?['lastname'] as String?) ?? '',
          roleId: 1,
          role: 'customer',
        );
      }
      return UserProfile.fromMap(data);
    } catch (_) {
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        firstname: '',
        lastname: '',
        roleId: 1,
        role: 'customer',
      );
    }
  }

  @override
  Future<void> signOut() => supabase.auth.signOut();
}
