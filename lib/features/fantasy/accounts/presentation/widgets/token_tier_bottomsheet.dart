import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/data/models/token_tier_model.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class TokenTierBottomSheet extends StatefulWidget {
  final AccountsUsecases accountsUsecases;
  final int enteredAmount;

  const TokenTierBottomSheet({
    super.key,
    required this.accountsUsecases,
    required this.enteredAmount,
  });

  @override
  State<TokenTierBottomSheet> createState() => _TokenTierBottomSheetState();
}

class _TokenTierBottomSheetState extends State<TokenTierBottomSheet> {
  late Future<List<TokenTierModel>?> tokenTierFuture;
  @override
  void initState() {
    super.initState();
    tokenTierFuture = widget.accountsUsecases.getTokenTiers(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            "Token Breakdown",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          FutureBuilder<List<TokenTierModel>?>(
            future: tokenTierFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: AppColors.lightCard,
                  highlightColor: AppColors.greyColor,
                  child: Column(
                    children: List.generate(2, (_) => _tierRowShimmer()),
                  ),
                );
              }

              final tiers = snapshot.data ?? [];

              if (tiers.isEmpty) {
                return const Text("No token data available");
              }

              return Column(
                children: tiers.map((tier) {
                  final isActive = widget.enteredAmount >= tier.minAmount &&
                      widget.enteredAmount <= tier.maxAmount;

                  return _tierRow(tier, isActive);
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _tierRow(TokenTierModel tier, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            isActive ? AppColors.mainColor.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.mainColor : AppColors.lightGrey,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "₹${tier.minAmount} – ₹${tier.maxAmount}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Image.asset(
                    Images.matchToken,
                    height: 12,
                  ),
                  Text(
                    " ${tier.tokenAmount}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                ],
              ),
              if (isActive)
                Text(
                  "You are in this tier",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.mainColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _tierRowShimmer() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.lightCard,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 14,
          width: 110,
          decoration: BoxDecoration(
            color: AppColors.greyColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 14,
              width: 70,
              decoration: BoxDecoration(
                color: AppColors.greyColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 10,
              width: 90,
              decoration: BoxDecoration(
                color: AppColors.greyColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
