// =============================================================================
// ARCHIVO: lib/core/services/update_service.dart
// FUNCIÓN: Verifica, descarga e instala actualizaciones automáticamente
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class UpdateService {
  final ApiService _apiService;

  UpdateService(this._apiService);

  /// Verifica si hay una actualización disponible
  Future<bool> checkForUpdates() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int currentVersionCode = int.parse(packageInfo.buildNumber);

      final Map<String, dynamic> latestVersion = await _apiService.getLatestVersion();
      final int latestVersionCode = latestVersion['versionCode'] as int;

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
        barrierDismissible: false,
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
                      _downloadAndInstallApk(context, downloadUrl, versionName);
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

  /// Descarga e instala el APK automáticamente
  Future<void> _downloadAndInstallApk(
      BuildContext context,
      String downloadUrl,
      String versionName,
      ) async {
    try {
      // 1. Solicitar permisos de almacenamiento
      if (Platform.isAndroid) {
        // Para Android 13+ (API 33+) ya no se necesita REQUEST_INSTALL_PACKAGES
        // pero para versiones anteriores sí
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          if (context.mounted) {
            _showErrorDialog(
              context,
              'Se requiere permiso para instalar aplicaciones de fuentes desconocidas.',
            );
          }
          return;
        }
      }

      // 2. Mostrar diálogo de progreso
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => _buildDownloadingDialog(0),
      );

      // 3. Descargar el APK
      final http.Response response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode != 200) {
        throw Exception('Error al descargar: ${response.statusCode}');
      }

      // 4. Guardar el APK en el almacenamiento local
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/prevenso_v$versionName.apk';
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // 5. Cerrar diálogo de progreso
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 6. Abrir el APK para instalarlo
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        throw Exception('Error al abrir el instalador: ${result.message}');
      }

    } catch (e) {
      debugPrint('Error al descargar/instalar APK: $e');

      // Cerrar diálogo de progreso si está abierto
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(
          context,
          'Error al descargar la actualización. Por favor, inténtalo de nuevo.',
        );
      }
    }
  }

  /// Diálogo de progreso de descarga
  Widget _buildDownloadingDialog(double progress) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A55A2)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Descargando actualización...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Por favor espera',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  /// Verifica y muestra el diálogo si hay actualización
  Future<void> checkAndShowUpdateDialog(BuildContext context) async {
    final bool hasUpdate = await checkForUpdates();
    if (hasUpdate && context.mounted) {
      await showUpdateDialog(context);
    }
  }
}