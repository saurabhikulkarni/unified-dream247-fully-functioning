import 'package:flutter/foundation.dart';

/// Provider for all players list
/// Manages player data for team selection
class AllPlayersProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _players = [];
  bool _isLoading = false;
  String? _error;
  String _filterRole = 'ALL';
  String _filterTeam = 'ALL';

  List<Map<String, dynamic>> get players {
    var filtered = _players;
    
    if (_filterRole != 'ALL') {
      filtered = filtered.where((p) => p['role'] == _filterRole).toList();
    }
    
    if (_filterTeam != 'ALL') {
      filtered = filtered.where((p) => p['team'] == _filterTeam).toList();
    }
    
    return List.unmodifiable(filtered);
  }
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterRole => _filterRole;
  String get filterTeam => _filterTeam;

  /// Fetch players for a match
  Future<void> fetchPlayers(String matchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch players
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock players data
      _players = [];
      
      debugPrint('Players fetched for match: $matchId');
    } catch (e) {
      _error = 'Error fetching players: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set role filter
  void setRoleFilter(String role) {
    _filterRole = role;
    notifyListeners();
  }

  /// Set team filter
  void setTeamFilter(String team) {
    _filterTeam = team;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _filterRole = 'ALL';
    _filterTeam = 'ALL';
    notifyListeners();
  }

  /// Get player by ID
  Map<String, dynamic>? getPlayerById(String playerId) {
    try {
      return _players.firstWhere((p) => p['id'] == playerId);
    } catch (e) {
      return null;
    }
  }
}
