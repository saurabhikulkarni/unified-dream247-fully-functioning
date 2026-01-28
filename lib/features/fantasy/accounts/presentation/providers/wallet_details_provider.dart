import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/balance_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';

class WalletDetailsProvider extends ChangeNotifier {
  BalanceModel? _walletData;
  BalanceModel? get walletData => _walletData;

  void setBalance(BalanceModel? value) {
    debugPrint('💰 [WALLET_PROVIDER] setBalance called');
    debugPrint('   - balance: ${value?.balance}');
    debugPrint('   - bonus: ${value?.bonus}');
    debugPrint('   - winning: ${value?.winning}');
    debugPrint('   - totalamount: ${value?.totalamount}');
    _walletData = value;
    notifyListeners();
  }

  /// Refresh wallet details from the backend API
  Future<void> refreshWalletDetails(BuildContext context) async {
    try {
      debugPrint('🔄 [WALLET_PROVIDER] Starting wallet refresh...');
      final datasource = AccountsDatasource(ApiImpl(), ApiImplWithAccessToken());
      final result = await datasource.myWalletDetails(context);
      debugPrint('✅ [WALLET_PROVIDER] Wallet refresh complete');
      debugPrint('   - Result: $result');
      // Note: myWalletDetails already calls setBalance on this provider
    } catch (e) {
      debugPrint('❌ [WALLET_PROVIDER] Error refreshing wallet details: $e');
    }
  }

  Future<void> clearWalletData() async {
    _walletData = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
