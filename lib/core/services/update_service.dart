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

  Future<bool> checkForUpdates() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int currentVersionCode = int.parse(packageInfo.buildNumber);

      final Map<String, dynamic> latestVersion =
      await _apiService.getLatestVersion();
      final int latestVersionCode = latestVersion['versionCode'] as int;

      return latestVersionCode > currentVersionCode;
    } catch (e) {
      debugPrint('Error al verificar actualizaciones: $e');
      return false;
    }
  }

  Future<void> showUpdateDialog(BuildContext context) async {
    try {
      final Map<String, dynamic> latestVersion =
      await _apiService.getLatestVersion();
      final String versionName = latestVersion['versionName'] as String;

      String? downloadUrl;
      if (Platform.isAndroid) {
        downloadUrl = latestVersion['url_android'] as String?;
      } else if (Platform.isWindows) {
        downloadUrl = latestVersion['url_windows'] as String?;
      }

      if (downloadUrl == null || downloadUrl.isEmpty) {
        debugPrint('No se encontró URL de descarga para esta plataforma.');
        return;
      }

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
                      _downloadAndInstallUpdate(
                          context, downloadUrl!, versionName);
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

  Future<void> _downloadAndInstallUpdate(
      BuildContext context,
      String downloadUrl,
      String versionName,
      ) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => _buildDownloadingDialog(0),
    );

    try {
      if (Platform.isAndroid) {
        await _handleAndroidUpdate(context, downloadUrl, versionName);
      } else if (Platform.isWindows) {
        await _handleWindowsUpdate(context, downloadUrl, versionName);
      } else {
        throw Exception('Plataforma no soportada para actualizaciones.');
      }

      if (context.mounted && Platform.isAndroid) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error al descargar/instalar: $e');

      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(
          context,
          'Error al descargar la actualización. Por favor, inténtalo de nuevo.',
        );
      }
    }
  }

  Future<void> _handleAndroidUpdate(
      BuildContext context, String downloadUrl, String versionName) async {
    final status = await Permission.requestInstallPackages.request();
    if (!status.isGranted) {
      throw Exception('Permiso de instalación denegado.');
    }

    final http.Response response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      throw Exception('Error al descargar: ${response.statusCode}');
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/prevenso_v$versionName.apk';
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Error al abrir el instalador: ${result.message}');
    }
  }

  Future<void> _handleWindowsUpdate(
      BuildContext context, String downloadUrl, String versionName) async {
    final http.Response response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      throw Exception('Error al descargar: ${response.statusCode}');
    }

    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('No se pudo encontrar el directorio de descargas.');
    }

    final String filePath = '${downloadsDir.path}/prevenso_v$versionName.zip';
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Error al abrir el archivo ZIP: ${result.message}');
    }

    if (context.mounted) {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Descarga Completa'),
          content: Text(
            'El archivo de actualización se guardó en tu carpeta de Descargas:\n\n$filePath\n\nPor favor, descomprímelo y reemplaza la versión actual.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

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

  Future<void> checkAndShowUpdateDialog(BuildContext context) async {
    final bool hasUpdate = await checkForUpdates();
    if (hasUpdate && context.mounted) {
      await showUpdateDialog(context);
    }
  }
}