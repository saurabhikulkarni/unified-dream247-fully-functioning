import 'package:universal_io/io.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class ApkReferralHelper {
  /// STEP 1: Permission
  static Future<bool> requestAllFilesPermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  /// STEP 2: Scan multiple possible directories (TEST ONLY)
  static Future<String?> getReferralFromApkName() async {
    try {
      final List<String> possibleDirs = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Android/data', // ⚠️ mostly blocked
        '/storage/emulated/0/Telegram',
        '/storage/emulated/0/Telegram/Apk',
        '/storage/emulated/0/WhatsApp/Media',
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Documents',
        '/storage/emulated/0/UCDownloads',
        '/storage/emulated/0/Samsung/Download',
      ];

      for (final path in possibleDirs) {
        final dir = Directory(path);

        if (!dir.existsSync()) continue;

        final files = dir.listSync(recursive: false);

        for (final file in files) {
          if (file is File && file.path.endsWith('.apk')) {
            final fileName = file.path.split('/').last;

            // Example: Dream247_AJAY.apk
            if (fileName.startsWith('Dream247_')) {
              final referralCode = fileName
                  .replaceFirst('Dream247_', '')
                  .replaceFirst('.apk', '');

              if (referralCode.isNotEmpty) {
                // Get.snackbar("APK FOUND", "$fileName from $path");
                printX('APK FOUND: $fileName from $path');
                return referralCode;
              }
            }
          }
        }
      }
    } catch (e) {
      // Get.snackbar("APK Scan Error", "$e");
      printX('APK scan error: $e');
    }

    return null;
  }
}
