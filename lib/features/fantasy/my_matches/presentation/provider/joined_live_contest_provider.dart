import 'package:flutter/foundation.dart';

/// Provider for joined live contests
/// Manages contests user has joined for ongoing matches
class JoinedLiveContestProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _contests = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get contests => List.unmodifiable(_contests);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch joined contests for a match
  Future<void> fetchJoinedContests(String matchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch joined contests
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock contests
      _contests = [];
      
      debugPrint('Joined contests fetched for match: $matchId');
    } catch (e) {
      _error = 'Error fetching joined contests: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get contest by ID
  Map<String, dynamic>? getContestById(String contestId) {
    try {
      return _contests.firstWhere((c) => c['id'] == contestId);
    } catch (e) {
      return null;
    }
  }
}
