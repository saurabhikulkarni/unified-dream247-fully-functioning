import 'package:flutter/material.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/accounts/data/models/balance_model.dart';

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
