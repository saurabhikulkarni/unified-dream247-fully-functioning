import 'package:unified_dream247/features/fantasy/accounts/data/models/token_tier_model.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/balance_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/bank_transfer_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/p2p_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/tds_dashboard_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/tds_transaction_history_list.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/transactions_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/user_transaction_detail_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/wallet_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/offers_model.dart';

abstract class AccountsRepositories {
  Future<Map<String, dynamic>?> requestAddCash(
    BuildContext context,
    String paymentMethod,
    String amount,
    String offerId,
  );

  Future<List<OffersModel>?>? getOffers(BuildContext context);

  Future<BankTransferModel?> requestWithdraw(
    BuildContext context,
    String amount,
  );

  Future<TransactionsModel?>? getTransactions(
    BuildContext context,
    String type,
    int skip,
    int limit,
    String status,
  );

  Future<TransactionsModel?>? getTransactionsRedis(
    BuildContext context,
    String type,
    int skip,
    int limit,
    String status,
  );

  Future<UsersTransactionDetailsModel?>? usersTransactionDetails(
    BuildContext context,
    String transactionId,
    String type,
  );
  Future<TdsTransactionHistoryList?>? getTdsTransactionHistory(
    BuildContext context,
    int skip,
    int limit,
  );

  Future<Map<String, dynamic>?> sabPaisaTxnResponse(
    BuildContext context,
    String amount,
    String orderId,
    String status,
    String txnId,
  );

  Future<BalanceModel?>? myWalletDetails(BuildContext context);

  Future<Map<String, dynamic>?> tdsDeductionDetails(
    BuildContext context,
    String amount,
  );

  Future<TdsDashboardModel?> tdsDashboard(BuildContext context);

  Future<WalletPaymentDoneModel?> walletTransfer(
    BuildContext context,
    String amount,
  );

  Future<Map<String, dynamic>?> p2pUserValidation(
    BuildContext context,
    String mobile,
  );

  Future<Map<String, dynamic>?> p2pSendOtp(BuildContext context);

  Future<P2pPaymentDoneModel?> verifyp2pOtp(
    BuildContext context,
    String mobile,
    String receiverId,
    String otp,
  );
  
  Future<List<TokenTierModel>?> getTokenTiers(
    BuildContext context,
  );

  Future<Map<String, dynamic>?> verifyRazorpayPayment(
    BuildContext context,
    String paymentId,
    String orderId,
    String signature,
  );

  Future<Map<String, dynamic>?> openMysteryBox(
    BuildContext context,
    String txnId,
  );

}
