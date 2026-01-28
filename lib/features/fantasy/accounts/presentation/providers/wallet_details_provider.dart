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
    } else {
      debugPrint('⚠️ [WALLET_PROVIDER_STATIC] No static instance available');
    }
  }

  void setBalance(BalanceModel? value) {
    debugPrint('💰 [WALLET_PROVIDER] setBalance called');
    if (value == null) {
      debugPrint('⚠️ [WALLET_PROVIDER] Balance is null');
    } else {
      debugPrint('   - balance: ${value.balance}');
      debugPrint('   - bonus: ${value.bonus}');
      debugPrint('   - winning: ${value.winning}');
      debugPrint('   - totalamount: ${value.totalamount}');
    }
    
    // ALWAYS update and notify, even if values appear unchanged
    // This ensures UI stays in sync, especially for initial loads
    _walletData = value;
    debugPrint('🔔 [WALLET_PROVIDER] Notifying listeners...');
    notifyListeners();
    debugPrint('✅ [WALLET_PROVIDER] Listeners notified');
  }

  /// Refresh wallet details from the backend API
  Future<void> refreshWalletDetails(BuildContext context) async {
    try {
      debugPrint('🔄 [WALLET_PROVIDER] Starting wallet refresh...');
      debugPrint('   - Context mounted: ${context.mounted}');
      debugPrint('   - Current balance before refresh: ${_walletData?.balance}');
      
      final datasource = AccountsDatasource(ApiImpl(), ApiImplWithAccessToken());
      final result = await datasource.myWalletDetails(context);
      
      if (result != null) {
        debugPrint('✅ [WALLET_PROVIDER] Wallet refresh complete');
        debugPrint('   - New balance: ${result.balance}');
        debugPrint('   - Current provider balance: ${_walletData?.balance}');
      } else {
        debugPrint('⚠️ [WALLET_PROVIDER] Wallet refresh returned null');
      }
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
