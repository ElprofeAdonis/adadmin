import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import 'auth_token_provider.dart';

@immutable
class AuthState {
  final bool isLoading;

  const AuthState({this.isLoading = false});

  AuthState copyWith({bool? isLoading}) {
    return AuthState(isLoading: isLoading ?? this.isLoading);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final AuthService _service = AuthService();

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login(String email, String pass, BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _service.login(email, pass);

      final role = result["rol"] as String?;
      final token = result["token"];
      final usuario = result["usuario"] as Map<String, dynamic>?;

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se recibió el rol del usuario.")),
        );
        return;
      }

      if (role == null || role.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se recibió el rol del usuario.")),
        );
        return;
      }

      ref
          .read(authSessionProvider.notifier)
          .setSession(token: token, role: role, user: usuario);

      // 🔁 Redirección por rol
      if (role == "SuperADMIN") {
        Navigator.pushReplacementNamed(
          context,
          '/super/dashboard',
          arguments: {
            'nombre': usuario?['nombre'] ?? '',
            'apellidos': usuario?['apellidos'] ?? '',
            'codigoUnico': usuario?['codigoUnico'] ?? '',
          },
        );
      } else if (role == "SECRETARIAAsociacion") {
        // De momento solo avisamos que no está implementado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dashboard de Secretaría aún no implementado"),
          ),
        );
      } else if (role == "PASTOR") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dashboard de Pastor aún no implementado"),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Rol no reconocido: $role")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al iniciar sesión: $e")));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void logout(BuildContext context) {
    ref.read(authSessionProvider.notifier).clear();
    Navigator.pushReplacementNamed(context, "/login");
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
