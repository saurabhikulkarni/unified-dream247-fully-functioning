import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/user_data.dart';

class UserDataProvider extends ChangeNotifier {
  UserFullDetailsResponse? _userData;

  UserFullDetailsResponse? get userData => _userData;

  void setUserData(UserFullDetailsResponse? value) async {
    _userData = value;
    notifyListeners();
  }

  void loadUserData(BuildContext context) async {
    try {
      final userDataString = await AppStorage.getStorageValueString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        debugPrint('No user data found in SharedPreferences.');
        _userData = null;
        await clearUserData();
        if (context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              AppNavigation.gotoLoginScreen(context);
            }
          });
        }
        return;
      }

      final dynamic decodedData = jsonDecode(userDataString);
      if (decodedData is Map<String, dynamic>) {
        _userData = UserFullDetailsResponse.fromJson(decodedData);
      } else {
        throw Exception('Decoded data is not a valid Map<String, dynamic>.');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      await clearUserData();
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go(RouteNames.login);
          }
        });
      }
    }
  }

  void updateUser(UserFullDetailsResponse? data) async {
    _userData = data;
    if (data != null) {
      await AppStorage.saveToStorageString(
        "userData",
        jsonEncode(data.toJson()),
      );
    } else {
      await AppStorage.clear();
    }
    notifyListeners();
  }

  Future<void> clearUserData() async {
    _userData = null;
    await AppStorage.saveToStorageString("userData", "");
    await AppStorage.saveToStorageString("authToken", "");
    await AppStorage.saveToStorageBool("loggedIn", false);
    notifyListeners();
  }
}
