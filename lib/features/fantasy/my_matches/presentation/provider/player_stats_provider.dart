import 'package:flutter/foundation.dart';

/// Provider for player statistics in live matches
/// Shows player performance and fantasy points
class PlayerStatsProvider extends ChangeNotifier {
  Map<String, Map<String, dynamic>> _playerStats = {};
  bool _isLoading = false;
  String? _error;

  Map<String, Map<String, dynamic>> get playerStats => Map.unmodifiable(_playerStats);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch player stats for a match
  Future<void> fetchPlayerStats(String matchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch player stats
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock player stats
      _playerStats = {};
      
      debugPrint('Player stats fetched for match: $matchId');
    } catch (e) {
      _error = 'Error fetching player stats: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get stats for a specific player
  Map<String, dynamic>? getPlayerStat(String playerId) {
    return _playerStats[playerId];
  }
}
