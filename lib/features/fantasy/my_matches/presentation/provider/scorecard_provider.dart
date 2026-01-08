import 'package:flutter/foundation.dart';

/// Provider for match scorecard
/// Shows detailed scorecard with innings breakdown
class ScorecardProvider extends ChangeNotifier {
  Map<String, dynamic>? _scorecard;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get scorecard => _scorecard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch scorecard for a match
  Future<void> fetchScorecard(String matchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch scorecard
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock scorecard data
      _scorecard = {
        'matchId': matchId,
        'innings': [],
      };
      
      debugPrint('Scorecard fetched for match: $matchId');
    } catch (e) {
      _error = 'Error fetching scorecard: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
