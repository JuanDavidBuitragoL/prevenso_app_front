// =============================================================================
// ARCHIVO: lib/core/services/update_service.dart
// FUNCIÓN: Verifica si hay actualizaciones disponibles
// =============================================================================

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class UpdateService {
  final ApiService _apiService;

  UpdateService(this._apiService);

  /// Verifica si hay una actualización disponible
  /// Retorna true si hay actualización, false si no
  Future<bool> checkForUpdates() async {
    try {
      // 1. Obtener la versión actual de la app instalada
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int currentVersionCode = int.parse(packageInfo.buildNumber);

      // 2. Obtener la última versión disponible del backend
      final Map<String, dynamic> latestVersion = await _apiService.getLatestVersion();
      final int latestVersionCode = latestVersion['versionCode'] as int;

      // 3. Comparar versiones
      return latestVersionCode > currentVersionCode;
    } catch (e) {
      debugPrint('Error al verificar actualizaciones: $e');
      return false;
    }
  }

  /// Muestra un diálogo informando sobre la actualización disponible
  Future<void> showUpdateDialog(BuildContext context) async {
    try {
      final Map<String, dynamic> latestVersion = await _apiService.getLatestVersion();
      final String versionName = latestVersion['versionName'] as String;
      final String downloadUrl = latestVersion['url_android'] as String;

      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false, // El usuario debe tomar una decisión
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A55A2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update,
                    color: Color(0xFF4A55A2),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Actualización Disponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Versión $versionName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A55A2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hay una nueva versión disponible con mejoras y correcciones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Deseas descargarla ahora?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _launchDownloadUrl(downloadUrl);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A55A2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Descargar Ahora',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Recordar más tarde',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          );
        },
      );
    } catch (e) {
      debugPrint('Error al mostrar diálogo de actualización: $e');
    }
  }

  /// Abre la URL de descarga en el navegador
  Future<void> _launchDownloadUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir la URL: $url');
    }
  }

  /// Verifica y muestra el diálogo si hay actualización (uso combinado)
  Future<void> checkAndShowUpdateDialog(BuildContext context) async {
    final bool hasUpdate = await checkForUpdates();
    if (hasUpdate && context.mounted) {
      await showUpdateDialog(context);
    }
  }
}