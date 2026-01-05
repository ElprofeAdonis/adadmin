import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthSession {
  final String? token;
  final String? role;
  final Map<String, dynamic>? user;

  const AuthSession({this.token, this.role, this.user});

  AuthSession copyWith({
    String? token,
    String? role,
    Map<String, dynamic>? user,
  }) {
    return AuthSession(
      token: token ?? this.token,
      role: role ?? this.role,
      user: user ?? this.user,
    );
  }
}

class AuthSessionNotifier extends Notifier<AuthSession> {
  @override
  AuthSession build() => const AuthSession();

  void setSession({
    required String token,
    required String role,
    required Map<String, dynamic>? user,
  }) {
    state = AuthSession(token: token, role: role, user: user);
  }

  void clear() {
    state = const AuthSession();
  }
}

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSession>(
  AuthSessionNotifier.new,
);
