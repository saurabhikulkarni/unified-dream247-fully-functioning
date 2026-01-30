import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/balance_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';

class WalletDetailsProvider extends ChangeNotifier {
  // Static instance for easy access from datasources without context gymnastics
  static WalletDetailsProvider? _staticInstance;
  
  BalanceModel? _walletData;
  BalanceModel? get walletData => _walletData;

  WalletDetailsProvider() {
    _staticInstance = this;
  }

  /// Static method to update balance without requiring context
  static void updateBalanceStatic(BalanceModel? value) {
    if (_staticInstance != null) {
      _staticInstance!.setBalance(value);
    }
  }

  void setBalance(BalanceModel? value) {
    // ALWAYS update and notify, even if values appear unchanged
    // This ensures UI stays in sync, especially for initial loads
    _walletData = value;
    notifyListeners();
  }

  /// Refresh wallet details from the backend API
  Future<void> refreshWalletDetails(BuildContext context) async {
    try {
      final datasource = AccountsDatasource(ApiImpl(), ApiImplWithAccessToken());
      await datasource.myWalletDetails(context);
      // Note: myWalletDetails already calls setBalance on this provider
    } catch (e) {
      debugPrint('❌ [WALLET_PROVIDER] Error refreshing wallet details: $e');
      debugPrint('❌ [WALLET_PROVIDER] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> clearWalletData() async {
    _walletData = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
