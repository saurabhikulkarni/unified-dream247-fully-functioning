import 'dart:convert';

import 'package:flutter/material.dart';
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
        debugPrint('📦 [UserDataProvider] No user data found in SharedPreferences.');
        debugPrint('📦 [UserDataProvider] This is normal if Fantasy module is initializing...');
        _userData = null;
        // DON'T redirect to login - let LandingPage handle authentication
        // The LandingPage will fetch user data during initialization
        notifyListeners();
        return;
      }

      final dynamic decodedData = jsonDecode(userDataString);
      if (decodedData is Map<String, dynamic>) {
        _userData = UserFullDetailsResponse.fromJson(decodedData);
        debugPrint('✅ [UserDataProvider] User data loaded: ${_userData?.name ?? _userData?.team ?? "Unknown"}');
      } else {
        throw Exception('Decoded data is not a valid Map<String, dynamic>.');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ [UserDataProvider] Error loading user data: $e');
      _userData = null;
      // DON'T redirect to login here - let LandingPage handle it
      notifyListeners();
    }
  }

  void updateUser(UserFullDetailsResponse? data) async {
    _userData = data;
    if (data != null) {
      await AppStorage.saveToStorageString(
        'userData',
        jsonEncode(data.toJson()),
      );
    } else {
      await AppStorage.clear();
    }
    notifyListeners();
  }

  Future<void> clearUserData() async {
    _userData = null;
    await AppStorage.saveToStorageString('userData', '');
    await AppStorage.saveToStorageString('authToken', '');
    await AppStorage.saveToStorageBool('loggedIn', false);
    notifyListeners();
  }
}
