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
      debugPrint('Error refreshing wallet details: $e');
    }
  }

  Future<void> clearWalletData() async {
    _walletData = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
