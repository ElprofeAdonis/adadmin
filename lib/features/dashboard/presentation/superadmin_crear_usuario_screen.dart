import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/presentation/providers/auth_token_provider.dart';
// 👆 ajusta esta ruta según tu proyecto (si tu provider está en otra carpeta)

class SuperAdminCrearUsuarioScreen extends ConsumerStatefulWidget {
  const SuperAdminCrearUsuarioScreen({super.key});

  @override
  ConsumerState<SuperAdminCrearUsuarioScreen> createState() =>
      _SuperAdminCrearUsuarioScreenState();
}

class _SuperAdminCrearUsuarioScreenState
    extends ConsumerState<SuperAdminCrearUsuarioScreen> {
  String _rol = "SECRETARIAAsociacion";

  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _codigo = TextEditingController();
  final _pass = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _telefono.dispose();
    _email.dispose();
    _pass.dispose();
    _codigo.dispose();
    super.dispose();
  }

  String _msgFromDioError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;

      // si backend manda { message: "..." }
      if (data is Map && data["message"] != null) {
        return data["message"].toString();
      }

      final status = e.response?.statusCode;

      if (status == 401) return "Token inválido o sesión expirada.";
      if (status == 403) return "No tienes permisos (debe ser SuperADMIN).";
      if (status == 409) return "Ya existe un usuario con esos datos.";
      if (status == 400) return "Datos inválidos. Revisa el formulario.";

      if (e.type == DioExceptionType.connectionTimeout) {
        return "Timeout de conexión.";
      }
      if (e.type == DioExceptionType.unknown) {
        return "No se pudo conectar al servidor.";
      }
      return "Error: ${e.message}";
    }
    return "Error inesperado.";
  }

  Future<void> _crear() async {
    // ✅ 1) Token (si es null => no hay sesión)
    final session = ref.read(authSessionProvider);
    final token = session.token;
    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesión expirada. Vuelve a iniciar sesión."),
        ),
      );
      return;
    }

    // ✅ 2) Validaciones rápidas
    final nombre = _nombre.text.trim();
    final apellidos = _apellidos.text.trim();
    final telefono = _telefono.text.trim();
    final email = _email.text.trim();
    final codigo = _codigo.text.trim();
    final pass = _pass.text.trim();

    if (nombre.isEmpty || apellidos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y apellidos son obligatorios")),
      );
      return;
    }
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email y contraseña son obligatorios")),
      );
      return;
    }
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código único es obligatorio")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ✅ 3) POST con Authorization
      final response = await DioClient.dio.post(
        "/api/usuario",
        data: {
          "nombre": nombre,
          "apellidos": apellidos,
          "telefono": telefono,
          "email": email,
          "password": pass,
          "rol": _rol,
          "codigoUnico": codigo,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final body = response.data;

      // tu backend puede responder { message, data } o directo el usuario
      Map<String, dynamic>? created;
      if (body is Map<String, dynamic>) {
        if (body["data"] is Map<String, dynamic>) {
          created = body["data"] as Map<String, dynamic>;
        } else {
          created = body;
        }
      }

      final userId = created?["id"]?.toString();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Usuario creado correctamente")),
      );

      // ✅ 4) Navegación según rol (si aplica)
      if (userId != null && userId.isNotEmpty) {
        if (_rol == "PASTOR") {
          Navigator.pushNamed(
            context,
            "/super/asignar-pastor",
            arguments: {
              "usuarioId": userId,
              "nombre": nombre,
              "apellidos": apellidos,
              "codigoUnico": codigo,
            },
          );
          return;
        }

        if (_rol == "SECRETARIAAsociacion") {
          Navigator.pushNamed(
            context,
            "/super/asignar-secretaria-asociacion",
            arguments: {"usuarioId": userId},
          );
          return;
        }

        if (_rol == "SECRETARIAIglesia") {
          Navigator.pushNamed(
            context,
            "/super/asignar-secretaria-iglesia",
            arguments: {"usuarioId": userId},
          );
          return;
        }

        if (_rol == "MIEMBRO") {
          Navigator.pushNamed(
            context,
            "/super/asignar-miembro",
            arguments: {"usuarioId": userId},
          );
          return;
        }
      }

      // si es SuperADMIN o no hay asignación => volvemos
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final msg = _msgFromDioError(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $msg")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear usuario"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Rol", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _rol,
              items: const [
                DropdownMenuItem(
                  value: "SuperADMIN",
                  child: Text("SuperADMIN"),
                ),
                DropdownMenuItem(
                  value: "SECRETARIAAsociacion",
                  child: Text("Secretaria de Asociación"),
                ),
                DropdownMenuItem(
                  value: "SECRETARIAIglesia",
                  child: Text("Secretaria de Iglesia"),
                ),
                DropdownMenuItem(value: "PASTOR", child: Text("Pastor")),
                DropdownMenuItem(value: "MIEMBRO", child: Text("Miembro")),
              ],
              onChanged: (v) => setState(() => _rol = v ?? _rol),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apellidos,
              decoration: const InputDecoration(
                labelText: "Apellidos",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefono,
              decoration: const InputDecoration(
                labelText: "Teléfono",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codigo,
              decoration: const InputDecoration(
                labelText: "Código único",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _crear,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Crear usuario"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
