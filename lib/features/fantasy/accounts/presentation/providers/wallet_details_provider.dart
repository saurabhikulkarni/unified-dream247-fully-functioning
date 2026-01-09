import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/balance_model.dart';

class WalletDetailsProvider extends ChangeNotifier {
  BalanceModel? _walletData;
  BalanceModel? get walletData => _walletData;

  void setBalance(BalanceModel? value) {
    _walletData = value;
    notifyListeners();
  }

  Future<void> clearWalletData() async {
    _walletData = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
