import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/singleton/app_singleton.dart';

class AppUpdateBottomSheet extends StatefulWidget {
  const AppUpdateBottomSheet({super.key});

  @override
  State<AppUpdateBottomSheet> createState() => _AppUpdateBottomSheetState();
}

class _AppUpdateBottomSheetState extends State<AppUpdateBottomSheet> {
  bool isShowDownload = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Update Available!',
                    style: GoogleFonts.tomorrow(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(Images.logo, height: 80, width: 150),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      AppUtils.htmlToPlainText(
                        AppSingleton.singleton.appData.point ?? "Updates",
                      ),
                      style: GoogleFonts.tomorrow(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  (isShowDownload == true)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Circular progress ring
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    value: _progress,
                                    strokeWidth: 6,
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.mainColor,
                                    ),
                                    backgroundColor: AppColors.lightGrey,
                                  ),
                                ),
                                // Center circular logo with 'W'
                                Opacity(
                                  opacity: 0.5,
                                  child: ClipOval(
                                    child: Image.asset(
                                      Images.logo,
                                      height: 65,
                                      width: 65,
                                    ),
                                  ),
                                ),
                                // Percentage text over everything
                                Text(
                                  "${(_progress * 100).toStringAsFixed(0)}%",
                                  style: GoogleFonts.exo2(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  MainButton(
                    text: Strings.updateNow,
                    onTap: () async {
                      if (Platform.isIOS) {
                      } else {
                        setState(() {
                          isShowDownload = true;
                          _downloadApk();
                        });
                      }
                    },
                    color: AppColors.green,
                    textColor: AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _progress = 0.0;
  bool isDownloading = true;
  File? _apkFile;
  final CancelToken _cancelToken = CancelToken();

  Future<void> _downloadApk() async {
    try {
      final downloadDirectory = await AppUtils.getDownloadDirectoryPath();
      final filePath =
          '$downloadDirectory/${AppSingleton.singleton.appData.apkname}';
      _apkFile = File(filePath);

      final Dio dio = Dio();

      // Check content length from HEAD request
      final headResponse = await dio.head(
        AppSingleton.singleton.appData.androidappurl ?? "",
      );
      final serverFileSize = int.tryParse(
        headResponse.headers.value(HttpHeaders.contentLengthHeader) ?? '',
      );

      final fileExists = await _apkFile!.exists();
      final localFileSize = fileExists ? await _apkFile!.length() : 0;

      if (fileExists &&
          serverFileSize != null &&
          localFileSize == serverFileSize) {
        debugPrint('APK already downloaded at $filePath');
        if (mounted) {
          Navigator.pop(context);
          await AppUtils.installApk(context, filePath);
        }
        return;
      }

      // Create directory if needed
      final dir = Directory(downloadDirectory);
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }

      await dio.download(
        AppSingleton.singleton.appData.androidappurl ?? "",
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _progress = received / total;
            });
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('APK Downloaded Successfully at: $filePath');

      if (mounted) {
        Navigator.pop(context);
        await AppUtils.installApk(context, filePath);
      }
    } catch (e) {
      debugPrint('Error downloading APK: $e');
      if (_apkFile != null && await _apkFile!.exists()) {
        await _apkFile!.delete(); // delete partially downloaded file
      }
      if (mounted) {
        appToast("Failed to Update App!", context);
        Navigator.pop(context);
      }
    }
  }
}
