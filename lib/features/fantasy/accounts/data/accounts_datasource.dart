// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:unified_dream247/features/fantasy/accounts/data/models/token_tier_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_keys.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/balance_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/bank_transfer_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/p2p_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/tds_dashboard_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/tds_transaction_history_list.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/transactions_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/user_transaction_detail_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/wallet_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/repositories/accounts_repositories.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/offers_model.dart';

class AccountsDatasource implements AccountsRepositories {
  ApiImpl client;
  ApiImplWithAccessToken clientWithToken;
  AccountsDatasource(this.client, this.clientWithToken);

  @override
  Future<Map<String, dynamic>?> requestAddCash(
    BuildContext context,
    String paymentMethod,
    String amount,
    String offerId,
  ) async {
    final url = APIServerUrl.depositServerUrl + APIServerUrl.newRequestAddCash;
    debugPrint('🔄 [ACCOUNTS_DS] requestAddCash URL: $url');
    final body = {
      ApiServerKeys.amount: amount,
      ApiServerKeys.paymentMethod: paymentMethod,
      ApiServerKeys.offerId: offerId,
    };
    debugPrint('📤 [ACCOUNTS_DS] Request body: $body');

    final response = await clientWithToken.post(url, body: body);
    final res = response.data;
    debugPrint('📥 [ACCOUNTS_DS] Response status: ${response.statusCode}');
    debugPrint('📥 [ACCOUNTS_DS] Response data: $res');
    
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        debugPrint('✅ [ACCOUNTS_DS] Add cash request successful');
        return response.data;
      } else {
        debugPrint('❌ [ACCOUNTS_DS] Add cash failed: ${res[ApiResponseString.message]}');
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      debugPrint('❌ [ACCOUNTS_DS] HTTP error: ${response.statusCode}');
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> sabPaisaTxnResponse(
    BuildContext context,
    String amount,
    String orderId,
    String status,
    String txnId,
  ) async {
    final url =
        APIServerUrl.depositServerUrl + APIServerUrl.sabPaisaTxnResponse;

    final body = {
      ApiServerKeys.userId:
          '${await AppStorage.getStorageValueString(AppStorageKeys.userId)}',
      ApiServerKeys.amount: amount,
      ApiServerKeys.orderId: orderId,
      ApiServerKeys.status: status,
      ApiServerKeys.txnId: txnId,
    };

    final response = await clientWithToken.post(url, body: body);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<OffersModel>?>? getOffers(BuildContext context) async {
    final url = APIServerUrl.depositServerUrl + APIServerUrl.getoffers;

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<OffersModel>.from(
          res[ApiResponseString.data].map((x) => OffersModel.fromJson(x)),
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<BankTransferModel?> requestWithdraw(
    BuildContext context,
    String amount,
  ) async {
    final url = APIServerUrl.withdrawServerUrl + APIServerUrl.requestwithdraw;

    final body = {
      ApiServerKeys.amount: amount,
      ApiServerKeys.withdrawFrom: 'WatchPay',
    };

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
        final data = BankTransferModel.fromJson(res[ApiResponseString.data]);
        Navigator.pop(context);
        AppNavigation.gotoBankPaymentSuccessDone(context, data);
        return data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
        Navigator.pop(context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> tdsDeductionDetails(
    BuildContext context,
    String amount,
  ) async {
    final url =
        APIServerUrl.withdrawServerUrl + APIServerUrl.tdsDeductionDetails;

    final body = {ApiServerKeys.amount: amount};

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<TransactionsModel?>? getTransactions(
    BuildContext context,
    String type,
    int skip,
    int limit,
    String status,
  ) async {
    final url =
        '${APIServerUrl.userServerUrl}${APIServerUrl.mytransactions}$type&skip=$skip&limit=$limit&status=$status';

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final transactions = TransactionsModel.fromJson(
          res[ApiResponseString.data],
        );
        return transactions;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<TransactionsModel?>? getTransactionsRedis(
    BuildContext context,
    String type,
    int skip,
    int limit,
    String status,
  ) async {
    final url =
        '${APIServerUrl.userServerUrl}${APIServerUrl.mytransactionsredis}$type&skip=$skip&limit=$limit&status=$status';

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final transactions = TransactionsModel.fromJson(
          res[ApiResponseString.data],
        );
        return transactions;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<UsersTransactionDetailsModel?>? usersTransactionDetails(
    BuildContext context,
    String transactionId,
    String type,
  ) async {
    final url =
        '${APIServerUrl.userServerUrl}${APIServerUrl.usersTransactionDetails}$transactionId&type=$type';

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final userTransactions = UsersTransactionDetailsModel.fromJson(
          res[ApiResponseString.data],
        );
        return userTransactions;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<TdsTransactionHistoryList?>? getTdsTransactionHistory(
    BuildContext context,
    int skip,
    int limit,
  ) async {
    final url =
        '${APIServerUrl.userServerUrl}${APIServerUrl.mytransactions}&skip=$skip&limit=$limit';

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final transactions = TdsTransactionHistoryList.fromJson(
          res[ApiResponseString.data],
        );
        return transactions;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<BalanceModel?>? myWalletDetails(BuildContext context) async {
    final url = '${APIServerUrl.userServerUrl}${APIServerUrl.myWalletDetails}';

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final balance = BalanceModel.fromJson(res[ApiResponseString.data]);
        Provider.of<WalletDetailsProvider>(
          context,
          listen: false,
        ).setBalance(balance);
        return balance;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<TdsDashboardModel?> tdsDashboard(BuildContext context) async {
    final url = '${APIServerUrl.withdrawServerUrl}${APIServerUrl.tdsDashboard}';

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final tdsDashboardData = TdsDashboardModel.fromJson(
          res[ApiResponseString.data],
        );
        return tdsDashboardData;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> p2pSendOtp(BuildContext context) async {
    final url = APIServerUrl.withdrawServerUrl + APIServerUrl.p2pSendOtp;

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> p2pUserValidation(
    BuildContext context,
    String mobile,
  ) async {
    final url = APIServerUrl.withdrawServerUrl +
        APIServerUrl.p2pUserValidation +
        mobile;

    final response = await clientWithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<WalletPaymentDoneModel?> walletTransfer(
    BuildContext context,
    String amount,
  ) async {
    final url = APIServerUrl.depositServerUrl + APIServerUrl.winningToDeposit;

    final body = {ApiServerKeys.amount: amount};

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
        final data = WalletPaymentDoneModel.fromJson(
          res[ApiResponseString.data],
        );
        Navigator.pop(context);
        AppNavigation.gotoWalletPaymentSuccessDone(context, data);
        return data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<P2pPaymentDoneModel?> verifyp2pOtp(
    BuildContext context,
    String amount,
    String receiverId,
    String otp,
  ) async {
    final url = APIServerUrl.withdrawServerUrl + APIServerUrl.verifyp2pOtp;

    final body = {
      ApiServerKeys.amount: num.parse(amount),
      '_id': receiverId,
      ApiServerKeys.otp: num.parse(otp),
    };

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
        final data = P2pPaymentDoneModel.fromJson(res[ApiResponseString.data]);
        Navigator.pop(context);
        AppNavigation.gotoPaymentSuccessDoneP2P(context, data);
        return data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  Future<List<TokenTierModel>?> getTokenTiers(
    BuildContext context,
  ) async {
    final url =
        APIServerUrl.depositServerUrl + APIServerUrl.tokenTier; // your endpoint

    final response = await clientWithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<TokenTierModel>.from(
          res[ApiResponseString.data].map((x) => TokenTierModel.fromJson(x)),
        );
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  // @override
  // Future<Map<String, dynamic>?> verifyRazorpayPayment(
  //   BuildContext context,
  //   String paymentId,
  //   String orderId,
  //   String signature,
  // ) async {
  //   final url = "";
  //   final body = {
  //     "razorpay_payment_id": paymentId,
  //     "razorpay_order_id": orderId,
  //     "razorpay_signature": signature,
  //   };
  //   final response = await clientWithToken.post(url, body: body);
  //   final res = response.data;
  //   return res;
  // }

  @override
  Future<Map<String, dynamic>?> verifyRazorpayPayment(
    BuildContext context,
    String paymentId,
    String orderId,
    String signature,
  ) async {
    final url =
        APIServerUrl.depositServerUrl + APIServerUrl.verifyRazorpayPayment;

    final body = {
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
      'razorpay_signature': signature,
    };

    final response = await clientWithToken.post(url, body: body);

    final Map<String, dynamic> res =
        response.data is String ? jsonDecode(response.data) : response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return res;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message] ?? 'Payment verification failed',
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> openMysteryBox(
    BuildContext context,
    String txnId,
  ) async {
    final url = APIServerUrl.depositServerUrl + APIServerUrl.openMysteryBox;

    final body = {'deposit_id': txnId};

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  /// Fetch game tokens balance from Fantasy backend after Razorpay payment
  /// Used to sync game tokens with backend after successful topup
  /// Response includes: balance, winning, bonus, totalamount
  Future<Map<String, dynamic>?> fetchGameTokensAfterPayment(
      BuildContext context) async {
    try {
      final url =
          '${APIServerUrl.userServerUrl}${APIServerUrl.myWalletDetails}';

      final response = await clientWithToken.get(url);
      final res = response.data;

      if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
        if (res[ApiResponseString.success] == true) {
          final data = res[ApiResponseString.data];
          debugPrint('✅ [FANTASY_API] Game tokens fetched: ${data['balance']}');
          return {
            'success': true,
            'data': data,
          };
        } else {
          debugPrint('❌ [FANTASY_API] Error: ${res['message']}');
          return {
            'success': false,
            'message': res['message'] ?? 'Failed to fetch game tokens',
          };
        }
      } else {
        if (context.mounted) {
          ApiServerUtil.manageException(response, context);
        }
        return {
          'success': false,
          'message': 'API Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ [FANTASY_API] Exception fetching game tokens: $e');
      return {
        'success': false,
        'message': 'Exception: $e',
      };
    }
  }
}
