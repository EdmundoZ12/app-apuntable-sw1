import 'package:apuntables/screens/SharedNotesScreen.dart';
import 'package:apuntables/screens/login_screen.dart';
import 'package:apuntables/screens/personal_notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apuntables/notificaciones/bloc/notifications_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Cambiado a dialogContext
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Cerrar sesión?',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const Text(
            '¿Estás seguro que deseas cerrar sesión?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Usando dialogContext
              },
            ),
            TextButton(
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                // Primero cerramos el diálogo usando dialogContext
                Navigator.of(dialogContext).pop();

                // Realizamos el logout
                await context.read<AuthProvider>().logout();

                // Verificamos si el widget aún está montado antes de navegar
                if (context.mounted) {
                  // Navegamos a la pantalla de login limpiando el stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Función para solicitar permisos de notificaciones
  Future<void> _requestNotificationPermission() async {
    // Obtenemos el bloc
    final notificationsBloc = context.read<NotificationsBloc>();

    try {
      // Solicitar permisos directamente usando Firebase Messaging
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Informar al bloc del cambio de estado
      notificationsBloc
          .add(NotificationStatusChanged(settings.authorizationStatus));

      // Mostrar mensaje según el resultado
      if (context.mounted) {
        String message;
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          message = 'Notificaciones activadas correctamente';
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          message = 'Notificaciones provisionales activadas';
        } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
          message = 'Permiso de notificaciones denegado';
        } else {
          message = 'No se pudo determinar el estado de las notificaciones';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF1E88E5),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error en caso de fallar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar permisos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // También intentamos la forma original como respaldo
      notificationsBloc.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    // Observamos el estado del bloc de notificaciones para actualizar el UI
    final notificationsState = context.watch<NotificationsBloc>().state;

    // Verificamos si las notificaciones están autorizadas
    final bool notificationsEnabled =
        notificationsState.status == AuthorizationStatus.authorized;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Apuntable',
            style: TextStyle(
              color: Color(0xFF1E88E5),
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: -0.5,
            )),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        actions: [
          // Icono de notificaciones (a la izquierda del icono de cerrar sesión)
          IconButton(
            icon: Icon(
              notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              size: 22,
            ),
            color: Color(0xFF1E88E5),
            tooltip: notificationsEnabled
                ? 'Notificaciones activas'
                : 'Activar notificaciones',
            onPressed: _requestNotificationPermission,
          ),
          // Icono de logout
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            color: Color(0xFF1E88E5),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Perfil del usuario con sombra sutil
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF1E88E5),
                      child: Text(
                        user?.nombre.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user?.nombre ?? ''} ${user?.apellido ?? ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Estadísticas con sombras suaves
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.assignment_outlined,
                    title: 'Tareas',
                    value: '0',
                  ),
                  const SizedBox(width: 20),
                  _buildStatCard(
                    icon: Icons.check_circle_outline,
                    title: 'Completadas',
                    value: '0',
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Menú con elementos elevados
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.book_outlined,
                    title: 'Mis Apuntes',
                    subtitle: 'Ver mis Propios Apuntes',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalNotesScreen(
                            userEmail: user?.email ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.share_sharp,
                    title: 'Compartidos conmigo',
                    subtitle: 'Ver Apuntes compartidos conmigo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SharedNotesScreen(
                            userEmail: user?.email ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: notificationsEnabled
                        ? 'Notificaciones activas'
                        : 'Activar notificaciones',
                    onTap: _requestNotificationPermission,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          height: 65,
          indicatorColor: const Color(0xFF1E88E5).withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 24, color: Colors.black54),
              selectedIcon:
                  Icon(Icons.home, size: 24, color: Color(0xFF1E88E5)),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined,
                  size: 24, color: Colors.black54),
              selectedIcon:
                  Icon(Icons.assignment, size: 24, color: Color(0xFF1E88E5)),
              label: 'Tareas',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined,
                  size: 24, color: Colors.black54),
              selectedIcon: Icon(Icons.calendar_today,
                  size: 24, color: Color(0xFF1E88E5)),
              label: 'Calendario',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 24, color: Colors.black54),
              selectedIcon:
                  Icon(Icons.person, size: 24, color: Color(0xFF1E88E5)),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Color(0xFF1E88E5),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF1E88E5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
