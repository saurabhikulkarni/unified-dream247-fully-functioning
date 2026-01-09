// // ignore_for_file: use_build_context_synchronously

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/api_server_constants/api_server_keys.dart';
import 'package:Dream247/core/api_server_constants/api_server_urls.dart';
import 'package:Dream247/core/api_server_constants/api_server_utils.dart';
import 'package:Dream247/core/app_constants/app_storage_keys.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/accounts/data/accounts_datasource.dart';
import 'package:Dream247/features/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:Dream247/features/menu_items/data/models/level_reward_model.dart';
import 'package:Dream247/features/menu_items/data/models/refer_users_model.dart';
import 'package:Dream247/features/menu_items/data/models/user_data.dart';
import 'package:Dream247/features/menu_items/domain/repositories/user_repositories.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDatasource extends UserRepositories {
  ApiImplWithAccessToken clientwithToken;
  UserDatasource(this.clientwithToken);

  @override
  Future<String?> uploadImage(BuildContext context, File userImage) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.imageUploadUser;
    debugPrint("Upload started...");
    debugPrint("URL: $url");

    try {
      final dio = Dio(); // Normal Dio instance

      // Convert file into multipart form data
      final fileName = userImage.path.split('/').last;
      debugPrint("File selected: $fileName");

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          userImage.path,
          filename: fileName,
        ),
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppStorageKeys.authToken);
      debugPrint("Token: $token");

      // Send POST request
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        onSendProgress: (sent, total) {
          final percent = (sent / total * 100).toStringAsFixed(0);
          debugPrint("Upload progress: $percent%");
        },
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Raw response data: ${response.data}");

      final res = response.data;

      if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
        if (res[ApiResponseString.success] == true) {
          debugPrint(
              "Upload success message: ${res[ApiResponseString.message]}");

          ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message],
            context,
          );

          // DEBUG: Check what exactly you’re returning
          debugPrint("Returning data: ${response.data.runtimeType}");
          final imageUrl = response.data['data']?['image_url'] as String?;
          return imageUrl;
        } else {
          debugPrint(
              "Upload failed message: ${res[ApiResponseString.message]}");
          ApiServerUtil.showAppToastforApi(
              res[ApiResponseString.message], context);
        }
      } else {
        debugPrint("Invalid status code: ${response.statusCode}");
        if (context.mounted) {
          ApiServerUtil.manageException(res, context);
        }
      }
    } catch (e, stack) {
      debugPrint('Image upload error: $e');
      debugPrint('StackTrace: $stack');
      if (context.mounted) {
        ApiServerUtil.showAppToastforApi('Image upload failed', context);
      }
    }

    return "";
  }

  // @override
  // Future<void> uploadImageToS3(
  //     File imageFile, String folderName, String fileName) async {
  //   final minio = Minio(
  //     endPoint: 's3.amazonaws.com',
  //     accessKey: dotenv.env['AWS_ACCESS_KEY'] ?? '',
  //     secretKey: dotenv.env['AWS_SECRET_KEY'] ?? '',
  //     region: 'ap-south-1',
  //   );

  //   try {
  //     String bucket = '${ApiServerurl.appname}-store';
  //     String objectName = '$folderName/$fileName';

  //     Stream<List<int>> fileStream = imageFile.openRead();
  //     Stream<Uint8List> uint8ListStream = fileStream.transform(
  //       StreamTransformer.fromHandlers(
  //         handleData: (List<int> data, EventSink<Uint8List> sink) {
  //           sink.add(Uint8List.fromList(data));
  //         },
  //       ),
  //     );

  //     var res = await minio.putObject(
  //       bucket,
  //       objectName,
  //       uint8ListStream,
  //       size: await imageFile.length(),
  //     );
  //     debugPrint('File uploaded successfully to S3.');
  //     debugPrint('Res : $res');
  //     debugPrint('Res : ${res.isEmpty}');
  //   } catch (e) {
  //     debugPrint('Error uploading file: $e');
  //   }
  // }

  @override
  Future<bool?> updateProfile(
    BuildContext context,
    String teamName,
    String name,
    String state,
    String gender,
    String city,
    String address,
    String dob,
    String pincode,
  ) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.editProfile;

    final body = {
      ApiServerKeys.name: name,
      ApiServerKeys.state: state,
      ApiServerKeys.gender: gender,
      ApiServerKeys.address: address,
      ApiServerKeys.city: city,
      ApiServerKeys.dob: dob,
      ApiServerKeys.pincode: pincode,
      ApiServerKeys.country: 'India',
    };
    if (Provider.of<UserDataProvider>(
          context,
          listen: false,
        ).userData?.teamNameUpdateStatus ==
        false) {
      body[ApiServerKeys.team] = teamName;
    }

    final response = await clientwithToken.post(url, body: body);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return true;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<bool?> editTeamName(
    BuildContext context,
    bool teamNameUpdateStatus,
  ) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.editTeamName;

    final body = {ApiServerKeys.teamNameUpdateStatus: teamNameUpdateStatus};

    final response = await clientwithToken.post(url, body: body);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return true;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<bool?> submitSupportRequest(
    BuildContext context,
    String email,
    String mobile,
    String reason,
    String message,
    File? supportImage,
  ) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.supportRequest;

    try {
      final dio = Dio();
      //Build multipart form data
      final formData = FormData.fromMap({
        ApiServerKeys.email: email,
        ApiServerKeys.mobile: mobile,
        ApiServerKeys.issue: reason,
        ApiServerKeys.message: message,
        if (supportImage != null)
          "image": await MultipartFile.fromFile(
            supportImage.path,
            filename: supportImage.path.split('/').last,
          ),
        'typename': 'support',
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppStorageKeys.authToken);
      debugPrint("Token: $token");

      // Send POST request
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        onSendProgress: (sent, total) {
          final percent = (sent / total * 100).toStringAsFixed(0);
          debugPrint("📦 Upload progress: $percent%");
        },
      );

      final res = response.data;

      if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
        if (res[ApiResponseString.success] == true) {
          ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message],
            context,
          );
          return true;
        } else {
          ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message],
            context,
          );
        }
      } else {
        if (context.mounted) {
          ApiServerUtil.manageException(response, context);
        }
      }
    } catch (e) {
      debugPrint("Support Request Error: $e");
      if (context.mounted) {
        ApiServerUtil.showAppToastforApi(
            "Failed to submit support request", context);
      }
    }

    return false;
  }

  @override
  Future<List<ReferUserModel>?>? getReferUsers(BuildContext context) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.getAllReferUsers;

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<ReferUserModel>.from(
          res[ApiResponseString.data].map((x) => ReferUserModel.fromJson(x)),
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<LevelRewardModel?> loadLevelRewards(BuildContext context) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.getLevelRewards;

    final response = await clientwithToken.get(url);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final levelData = LevelRewardModel.fromJson(res);
        return levelData;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<bool?> getUserDetails(BuildContext context) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.getUserDetails;

    final response = await clientwithToken.get(url);

    var res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final userDetails = UserFullDetailsResponse.fromJson(
          res[ApiResponseString.data],
        );

        await AppStorage.saveToStorageString(
          AppStorageKeys.userId,
          res[ApiResponseString.data][ApiResponseString.userId],
        );
        await AppStorage.saveToStorageString(
          "userData",
          jsonEncode(userDetails.toJson()),
        );
        if (context.mounted) {
          Provider.of<UserDataProvider>(
            context,
            listen: false,
          ).setUserData(userDetails);
          final accountsUsecases = AccountsUsecases(
            AccountsDatasource(ApiImpl(), clientwithToken),
          );
          await accountsUsecases.myWalletDetails(context);
        }
      }
      return true;
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }
}
