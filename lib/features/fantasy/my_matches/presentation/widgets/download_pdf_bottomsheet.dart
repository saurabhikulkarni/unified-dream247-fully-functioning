// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/api_server_constants/api_server_urls.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_storage_keys.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/global_widgets/app_toast.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/my_matches/data/models/team_pdf_range_model.dart';
import 'package:Dream247/features/my_matches/data/my_matches_datasource.dart';
import 'package:Dream247/features/my_matches/domain/use_cases/my_matches_usecases.dart';

class DownloadPdfBottomsheet extends StatefulWidget {
  final String challengeId;
  const DownloadPdfBottomsheet({super.key, required this.challengeId});

  @override
  State<DownloadPdfBottomsheet> createState() => _DownloadPdfBottomsheetState();
}

class _DownloadPdfBottomsheetState extends State<DownloadPdfBottomsheet> {
  Future<List<TeamPdfRangeModel>?>? teamFilesPdf;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    teamFilesPdf = myMatchesUsecases.getTeamFilesPdf(
      context,
      widget.challengeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 15),
                        child: Text(
                          'Download Teams',
                          style: TextStyle(
                            color: AppColors.letterColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.letterColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 94,
                    width: 94,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: AppColors.bgColor,
                    ),
                    child: Image.asset(Images.imageDownloadTeam),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 10),
                    child: Text(
                      'Teams Locked! Download and track your competition',
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.letterColor, thickness: 0.4),
                  FutureBuilder(
                    future: teamFilesPdf,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            // child: LoadingIndicator(
                            //   strokeWidth: 1.0,
                            //   indicatorType: Indicator.lineSpinFadeLoader,
                            //   backgroundColor: AppColors.transparent,
                            //   pathBackgroundColor: AppColors.transparent,
                            //   colors: [
                            //     AppColors.letterColor,
                            //     AppColors.greyColor
                            //   ],
                            // ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data?.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Team ${snapshot.data?[index].min} - ${snapshot.data?[index].max}',
                                  style: const TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    String pdfUrl =
                                        '${APIServerUrl.otherApiServerUrl}renderCreatePdf?challengeid=${widget.challengeId}&index=$index';
                                    debugPrint(pdfUrl);
                                    String fileName =
                                        '${APIServerUrl.appName}-Contest-${widget.challengeId}.pdf';
                                    downloadPdf(pdfUrl, fileName, context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.letterColor,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Image.asset(
                                        Images.imageDownloadIcon,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadPdf(
    String url,
    String fileName,
    BuildContext context,
  ) async {
    try {
      final directory = await getDownloadDirectoryPath();
      final filePath = "${directory.path}/$fileName";

      final authToken = await AppStorage.getStorageValueString(
        AppStorageKeys.authToken,
      );

      Dio dio = Dio();

      await dio.download(
        url,
        filePath,
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      appToast("PDF downloaded to $filePath", context);
      await openFile(filePath);
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
      appToast("Failed to download PDF. Please try again.", context);
    }
  }

  Future<Directory> getDownloadDirectoryPath() async {
    if (Platform.isAndroid) {
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        return Directory('${directory.path}/Download');
      } else {
        throw Exception("Failed to get download directory.");
      }
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  Future<void> openFile(String filePath) async {
    if (await File(filePath).exists()) {
      await OpenFile.open(filePath);
    } else {
      debugPrint("File not found: $filePath");
    }
  }
}
