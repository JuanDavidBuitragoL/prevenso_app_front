// features/home/presentation/pages/home_page.dart
// Se ajusta el espaciado para la nueva AppBar y se agrega
// verificación automática de actualizaciones.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/update_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/action_buttons_grid.dart';
import '../widgets/recent_quotes_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UpdateService _updateService;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();

    // Inicializar el servicio de actualizaciones
    _updateService = UpdateService(ApiService());

    // Verificar actualizaciones al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  /// Verifica si hay actualizaciones disponibles
  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdate) return; // Evitar múltiples verificaciones simultáneas

    setState(() => _isCheckingUpdate = true);

    try {
      await _updateService.checkAndShowUpdateDialog(context);
    } catch (e) {
      debugPrint('Error al verificar actualizaciones: $e');
      // No mostramos error al usuario para no interrumpir la experiencia
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdate = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para acceder al AuthProvider y reconstruir si cambia.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.user?.nombre_usuario ?? 'Usuario';
        final firstName = userName.split(' ').first;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Hola, $firstName',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A55A2),
                        ),
                      ),
                    ),
                    // Botón para verificar actualizaciones manualmente
                    IconButton(
                      icon: _isCheckingUpdate
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4A55A2),
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.system_update,
                        color: Color(0xFF4A55A2),
                      ),
                      tooltip: 'Buscar actualizaciones',
                      onPressed: _isCheckingUpdate ? null : _checkForUpdates,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const ActionButtonsGrid(),
                const SizedBox(height: 40),
                const RecentQuotesSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}