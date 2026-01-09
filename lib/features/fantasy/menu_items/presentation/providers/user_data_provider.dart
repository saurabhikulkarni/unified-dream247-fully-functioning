import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/app_storage_keys.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/menu_items/data/models/user_data.dart';
import 'package:Dream247/features/onboarding/presentation/screens/login_screen.dart';

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
            // AppNavigation.gotoLoginScreen(context);
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
    await AppStorage.saveToStorageString(AppStorageKeys.authToken, "");
    await AppStorage.saveToStorageBool(AppStorageKeys.logedIn, false);
    notifyListeners();
  }
}
