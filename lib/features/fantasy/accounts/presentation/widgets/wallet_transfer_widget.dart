// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';

class WalletTransferWidget extends StatefulWidget {
  final String? amount;
  const WalletTransferWidget({super.key, this.amount});

  @override
  State<WalletTransferWidget> createState() => _WalletTransferWidgetState();
}

class _WalletTransferWidgetState extends State<WalletTransferWidget> {
  num calculateCashbackAmount() {
    try {
      final num withdrawal = num.tryParse(widget.amount ?? '0') ?? 0;
      final cashbackRate = num.tryParse(
            AppSingleton.singleton.appData.winningDepositCashback.toString(),
          ) ??
          0;

      return (withdrawal * cashbackRate) / 100;
    } catch (e) {
      debugPrint('Error in calculating cashback: $e');
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.green.withAlpha(26),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Withdraw Amount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: '₹',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.letterColor,
                      ),
                      children: [
                        TextSpan(
                          text: widget.amount,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Get',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                      ),
                      children: [
                        TextSpan(
                          text: (AppSingleton.singleton.appData
                                      .winningDepositCashback ==
                                  null)
                              ? ' 10% '
                              : ' ${AppSingleton.singleton.appData.winningDepositCashback}% ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                        const TextSpan(
                          text: 'Extra Cash',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: '₹',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.green,
                      ),
                      children: [
                        TextSpan(
                          text: '${calculateCashbackAmount()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Received In Deposit Wallet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: '₹',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.letterColor,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${(num.tryParse(widget.amount ?? "0") ?? 0) + calculateCashbackAmount()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
