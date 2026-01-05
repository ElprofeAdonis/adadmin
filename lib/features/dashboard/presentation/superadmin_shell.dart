import 'package:flutter/material.dart';
import 'superadmin_dashboard_screen.dart'; // tu dashboard actual (wrapper o screen)
import 'superadmin_analiticas_screen.dart';
import 'superadmin_usuarios_screen.dart';
import 'superadmin_crear_usuario_screen.dart';
import 'superadmin_reportes_screen.dart';

class SuperAdminShell extends StatefulWidget {
  const SuperAdminShell({super.key});

  @override
  State<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends State<SuperAdminShell> {
  int _index = 0;

  final _pages = const [
    // ✅ Home: tu dashboard (recomendado usar el WRAPPER que trae el provider)
    SuperAdminDashboardWrapper(),

    // 🧩 Pantallas nuevas
    SuperAdminAnaliticasScreen(),
    SuperAdminUsuariosScreen(),
    SuperAdminCrearUsuarioScreen(),
    SuperAdminReportesScreen(),
  ];

  final _titles = const [
    "ADAdmin - SuperADMIN",
    "Análisis",
    "Usuarios",
    "Crear usuario",
    "Reportes",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), centerTitle: true),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed, // 👈 necesario para 5 items
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: "Análisis",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: "Usuarios",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_outlined),
            label: "Crear",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "Reportes",
          ),
        ],
      ),
    );
  }
}
