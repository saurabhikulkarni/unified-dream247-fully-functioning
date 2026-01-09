// ignore_for_file: use_build_context_synchronously

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';

class BankTransferWidget extends StatelessWidget {
  final String? bankAccNo;
  const BankTransferWidget({super.key, this.bankAccNo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40.0),
        const Text(
          'Withdraw Methods',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5.0),
        RichText(
          text: TextSpan(
            text: "Use Bank Transfer when you withdraw more than ",
            style: const TextStyle(
              fontSize: 12.0,
              color: AppColors.letterColor,
              fontWeight: FontWeight.w300,
            ),
            children: <TextSpan>[
              TextSpan(
                text:
                    "${Strings.indianRupee}${AppSingleton.singleton.appData.minwithdraw}",
                style: GoogleFonts.tomorrow(
                  fontSize: 12.0,
                  color: AppColors.letterColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            leading: const Icon(Icons.account_balance, color: Colors.blue),
            title: const Text(
              'Bank Transfer',
              style: TextStyle(
                color: AppColors.letterColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              AppUtils.maskDigits(bankAccNo ?? "---", 4),
              style: const TextStyle(
                color: AppColors.letterColor,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
