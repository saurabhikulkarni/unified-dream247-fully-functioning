import 'package:unified_dream247/features/fantasy/features/accounts/data/models/token_tier_model.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/bank_transfer_model.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/domain/repositories/accounts_repositories.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/balance_model.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/p2p_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/tds_dashboard_model.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/tds_transaction_history_list.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/transactions_model.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/user_transaction_detail_model.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/wallet_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/data/models/offers_model.dart';

class AccountsUsecases {
  AccountsRepositories accountsRepositories;
  AccountsUsecases(this.accountsRepositories);

  Future<Map<String, dynamic>?> requestAddCash(
    BuildContext context,
    String paymentMethod,
    String amount,
    String offerId,
  ) async {
    var res = await accountsRepositories.requestAddCash(
      context,
      paymentMethod,
      amount,
      offerId,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> sabPaisaTxnResponse(
    BuildContext context,
    String amount,
    String orderId,
    String status,
    String txnId,
  ) async {
    var res = await accountsRepositories.sabPaisaTxnResponse(
      context,
      amount,
      orderId,
      status,
      txnId,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<OffersModel>?>? getOffers(BuildContext context) async {
    var res = await accountsRepositories.getOffers(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<BankTransferModel?> requestWithdraw(
    BuildContext context,
    String amount,
  ) async {
    var res = await accountsRepositories.requestWithdraw(context, amount);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<TransactionsModel?>? getTransactions(
    BuildContext context,
    String type,
    int skip,
    int limit,
    String status,
  ) async {
    var res = await accountsRepositories.getTransactions(
      context,
      type,
      skip,
      limit,
      status,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<TransactionsModel?>? getTransactionsRedis(
    BuildContext context,
    String type,
    int skip,
    int limit,
    String status,
  ) async {
    var res = await accountsRepositories.getTransactionsRedis(
      context,
      type,
      skip,
      limit,
      status,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<UsersTransactionDetailsModel?>? usersTransactionDetails(
    BuildContext context,
    String transactionId,
    String type,
  ) async {
    var res = await accountsRepositories.usersTransactionDetails(
      context,
      transactionId,
      type,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<TdsTransactionHistoryList?>? getTdsTransactionHistory(
    BuildContext context,
    int skip,
    int limit,
  ) async {
    var res = await accountsRepositories.getTdsTransactionHistory(
      context,
      skip,
      limit,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<BalanceModel?>? myWalletDetails(BuildContext context) async {
    var res = await accountsRepositories.myWalletDetails(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> tdsDeductionDetails(
    BuildContext context,
    String amount,
  ) async {
    var res = await accountsRepositories.tdsDeductionDetails(context, amount);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<TdsDashboardModel?> tdsDashboard(BuildContext context) async {
    var res = await accountsRepositories.tdsDashboard(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> p2pSendOtp(BuildContext context) async {
    var res = await accountsRepositories.p2pSendOtp(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> p2pUserValidation(
    BuildContext context,
    String mobile,
  ) async {
    var res = await accountsRepositories.p2pUserValidation(context, mobile);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<WalletPaymentDoneModel?> walletTransfer(
    BuildContext context,
    String amount,
  ) async {
    var res = await accountsRepositories.walletTransfer(context, amount);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<P2pPaymentDoneModel?> verifyp2pOtp(
    BuildContext context,
    String amount,
    String receiverId,
    String otp,
  ) async {
    var res = await accountsRepositories.verifyp2pOtp(
      context,
      amount,
      receiverId,
      otp,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<TokenTierModel>?> getTokenTiers(
    BuildContext context,
  ) async {
    final res = await accountsRepositories.getTokenTiers(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> verifyRazorpayPayment(
    BuildContext context,
    String paymentId,
    String orderId,
    String signature,
  ) async {
    final res = await accountsRepositories.verifyRazorpayPayment(
      context,
      paymentId,
      orderId,
      signature,
    );

    return res; // return full response
  }
  Future<Map<String, dynamic>?> openMysteryBox(
    BuildContext context,
    String txnId,
  ) async {
    var res = await accountsRepositories.openMysteryBox(context, txnId);
    if (res != null) {
      return res;
    }
    return null;
  }

}
