import 'package:flutter/foundation.dart';

/// Provider for user profile data in fantasy gaming
/// Manages user information, statistics, and profile updates
class UserDataProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get userName => _userData?['name'] ?? 'User';
  String get userEmail => _userData?['email'] ?? '';
  String get userPhone => _userData?['phone'] ?? '';
  String? get userAvatar => _userData?['avatar'];
  int get totalMatches => _userData?['totalMatches'] ?? 0;
  int get totalWins => _userData?['totalWins'] ?? 0;
  double get totalWinnings => (_userData?['totalWinnings'] ?? 0.0).toDouble();

  /// Fetch user data from API
  Future<void> fetchUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch user data
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _userData = {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '+91 9876543210',
        'avatar': null,
        'totalMatches': 45,
        'totalWins': 12,
        'totalWinnings': 5430.0,
        'joinDate': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
      };
      
      debugPrint('User data fetched successfully');
    } catch (e) {
      _error = 'Error fetching user data: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to update profile
      await Future.delayed(const Duration(seconds: 1));
      
      _userData = {...?_userData, ...updates};
      
      debugPrint('Profile updated successfully');
      return true;
    } catch (e) {
      _error = 'Error updating profile: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user avatar
  Future<bool> updateAvatar(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to upload avatar
      await Future.delayed(const Duration(seconds: 2));
      
      _userData?['avatar'] = imagePath;
      
      debugPrint('Avatar updated successfully');
      return true;
    } catch (e) {
      _error = 'Error updating avatar: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
