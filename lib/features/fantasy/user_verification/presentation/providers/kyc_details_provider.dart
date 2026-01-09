import 'package:flutter/material.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/user_verification/data/models/kyc_detail_model.dart';

class KycDetailsProvider extends ChangeNotifier {
  KycDetailsModel? _kycData;
  KycDetailsModel? get kycData => _kycData;

  ValueNotifier<int> aadharVerifiedStatus = ValueNotifier<int>(-1);
  ValueNotifier<int> panVerifiedStatus = ValueNotifier<int>(-1);
  ValueNotifier<int> bankVerifiedStatus = ValueNotifier<int>(-1);

  void setkycData(KycDetailsModel? value) async {
    _kycData = value;
    notifyListeners();
  }

  void clearkycData() async {
    _kycData = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
