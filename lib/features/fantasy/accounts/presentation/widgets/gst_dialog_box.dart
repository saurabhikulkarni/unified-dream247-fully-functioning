import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/widgets/gst_container.dart';

class GstDialogBox extends StatefulWidget {
  final String amount;
  final bool? isExpanded;
  const GstDialogBox({super.key, required this.amount, this.isExpanded});

  @override
  State<GstDialogBox> createState() => _GstDialogBoxState();
}

class _GstDialogBoxState extends State<GstDialogBox> {
  bool isExpanded = false;

  double calculateExclusiveAmount(double depositedAmount) {
    return (depositedAmount * 100) / 128;
  }

  double calculateGovtTax(double depositedAmount) {
    double exclusiveAmount = calculateExclusiveAmount(depositedAmount);
    return depositedAmount - exclusiveAmount;
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double depositedAmount = double.tryParse(widget.amount) ?? 0.0;
    double exclusiveAmount = calculateExclusiveAmount(depositedAmount);
    double govtTax = calculateGovtTax(depositedAmount);

    return GstDetailContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Cash to Current Balance",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.letterColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    "${Strings.indianRupee}${formatAmount(depositedAmount)}",
                    style: GoogleFonts.tomorrow(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.letterColor,
                    ),
                  ),
                  InkWell(
                    child: Icon(
                      (isExpanded)
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      size: 25,
                    ),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          (isExpanded)
              ? Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: MediaQuery.of(context).size.width * .90,
                      height: 1,
                      color: AppColors.lightGrey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Text(
                            "Deposit Amount (excl. Govt. Tax)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.letterColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 21,
                            height: 17,
                            color: AppColors.lightBlue,
                            child: const Center(
                              child: Text(
                                "A",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.letterColor,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${Strings.indianRupee}${formatAmount(exclusiveAmount)}",
                            style: GoogleFonts.tomorrow(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Govt. Tax (28% GST)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.letterColor,
                            ),
                          ),
                          Text(
                            "${Strings.indianRupee}${formatAmount(govtTax)}",
                            style: GoogleFonts.tomorrow(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.letterColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .90,
                        height: 1,
                        color: AppColors.lightGrey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.letterColor,
                            ),
                          ),
                          Text(
                            "${Strings.indianRupee}${formatAmount(depositedAmount)}",
                            style: GoogleFonts.tomorrow(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.letterColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 17,
                                width: 17,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  color: AppColors.green.withAlpha(20),
                                ),
                                child: const Center(
                                  child: Text(
                                    "%",
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Discount Point Worth",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.letterColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 21,
                                height: 17,
                                color: AppColors.lightBlue,
                                child: const Center(
                                  child: Text(
                                    "B",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.letterColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${Strings.indianRupee}${formatAmount(govtTax)}",
                            style: GoogleFonts.tomorrow(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .90,
                        height: 1,
                        color: AppColors.lightGrey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Add to Current Balance",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.letterColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 21,
                                height: 17,
                                color: AppColors.lightBlue,
                                child: const Center(
                                  child: Text(
                                    "A",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.letterColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.add, size: 14),
                              const SizedBox(width: 4),
                              Container(
                                width: 21,
                                height: 17,
                                color: AppColors.lightBlue,
                                child: const Center(
                                  child: Text(
                                    "B",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.letterColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${Strings.indianRupee}${formatAmount(depositedAmount)}",
                            style: GoogleFonts.tomorrow(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
