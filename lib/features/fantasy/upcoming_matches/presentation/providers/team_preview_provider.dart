import 'package:flutter/foundation.dart';

/// Provider for team preview functionality
/// Shows team composition and validates team before saving
class TeamPreviewProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _selectedPlayers = [];
  String? _captainId;
  String? _viceCaptainId;
  bool _isValid = false;

  List<Map<String, dynamic>> get selectedPlayers => List.unmodifiable(_selectedPlayers);
  String? get captainId => _captainId;
  String? get viceCaptainId => _viceCaptainId;
  bool get isValid => _isValid;

  int get wicketKeepersCount => _selectedPlayers.where((p) => p['role'] == 'WK').length;
  int get battersCount => _selectedPlayers.where((p) => p['role'] == 'BAT').length;
  int get allRoundersCount => _selectedPlayers.where((p) => p['role'] == 'AR').length;
  int get bowlersCount => _selectedPlayers.where((p) => p['role'] == 'BOWL').length;

  /// Add player to team
  void addPlayer(Map<String, dynamic> player) {
    if (_selectedPlayers.length < 11) {
      _selectedPlayers.add(player);
      _validateTeam();
      notifyListeners();
    }
  }

  /// Remove player from team
  void removePlayer(String playerId) {
    _selectedPlayers.removeWhere((p) => p['id'] == playerId);
    
    // Clear captain/vice-captain if removed
    if (_captainId == playerId) _captainId = null;
    if (_viceCaptainId == playerId) _viceCaptainId = null;
    
    _validateTeam();
    notifyListeners();
  }

  /// Set captain
  void setCaptain(String playerId) {
    if (_selectedPlayers.any((p) => p['id'] == playerId)) {
      _captainId = playerId;
      _validateTeam();
      notifyListeners();
    }
  }

  /// Set vice-captain
  void setViceCaptain(String playerId) {
    if (_selectedPlayers.any((p) => p['id'] == playerId)) {
      _viceCaptainId = playerId;
      _validateTeam();
      notifyListeners();
    }
  }

  /// Validate team composition
  void _validateTeam() {
    _isValid = _selectedPlayers.length == 11 &&
        wicketKeepersCount >= 1 &&
        battersCount >= 3 &&
        allRoundersCount >= 1 &&
        bowlersCount >= 3 &&
        _captainId != null &&
        _viceCaptainId != null &&
        _captainId != _viceCaptainId;
  }

  /// Clear team
  void clearTeam() {
    _selectedPlayers.clear();
    _captainId = null;
    _viceCaptainId = null;
    _isValid = false;
    notifyListeners();
  }

  /// Get team credits used
  double get creditsUsed {
    return _selectedPlayers.fold(0.0, (sum, player) {
      return sum + (player['credits'] ?? 0.0);
    });
  }
}
