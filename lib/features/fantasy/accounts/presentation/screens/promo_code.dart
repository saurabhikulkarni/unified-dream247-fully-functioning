import 'dart:math';

import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/data/models/offers_model.dart';
import 'package:flutter/material.dart';

class PromoCode extends StatefulWidget {
  final String? amount;
  final bool? isApplied;
  final Future<List<OffersModel>?>? offerList;
  const PromoCode({super.key, this.offerList, this.amount, this.isApplied});
  @override
  State<PromoCode> createState() => _PromoCode();
}

class _PromoCode extends State<PromoCode> {
  bool isApplied = false;
  String promoId = "";

  @override
  void initState() {
    super.initState();
    isApplied = widget.isApplied ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.addCash,
      addPadding: false,
      child: FutureBuilder(
        future: widget.offerList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 20,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ShimmerWidget(
                  height: 100,
                  margin: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width / 3,
                );
              },
            );
          } else {
            return snapshot.data!.isEmpty
                ? Container()
                : ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return singleItemOfferCode(snapshot.data![index]);
                    },
                  );
          }
        },
      ),
    );
  }

  Widget singleItemOfferCode(OffersModel data) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(Images.imageAddCashLeft),
          fit: BoxFit.none,
          scale: 2,
          alignment: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Transform.rotate(
              angle: -pi / 2,
              child: Column(
                children: [
                  const Text(
                    'Use Code',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    '${data.offerCode}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.whiteFade1, width: 2),
                gradient: const LinearGradient(
                  colors: [Color(0xFFfde0e0), Color(0xFFf9f8f8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: Text(
                      data.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: Text(
                      data.description!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 1,
                    endIndent: 1,
                    color: AppColors.whiteFade1,
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valid Till : ${AppUtils.formatCustomDate(data.enddate!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: AppColors.letterColor,
                              ),
                            ),
                            Text(
                              "Min Amt: ${Strings.indianRupee}${data.minAmount}, Max Amt: ${Strings.indianRupee}${data.maxAmount}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: AppColors.letterColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 95,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.amount != null &&
                                  num.parse(widget.amount.toString()) >=
                                      (data.minAmount ?? 0) &&
                                  num.parse(widget.amount.toString()) <=
                                      (data.maxAmount ?? 0)) {
                                if ((data.usedCount ?? 0) >=
                                    (data.userTime ?? 1)) {
                                  appToast(
                                    "You have already exhausted limit to use this offer code.",
                                    context,
                                  );
                                  setState(() {
                                    promoId = "";
                                    isApplied = false;
                                  });
                                } else {
                                  setState(() {
                                    promoId = data.id ?? "";
                                    isApplied = true;
                                    appToast(Strings.promoCodeApplied, context);
                                  });
                                }
                              } else {
                                setState(() {
                                  promoId = "";
                                  isApplied = false;
                                  appToast(
                                    Strings.promoCodeNotApplied,
                                    context,
                                  );
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                ((data.usedCount ?? 0) >= (data.userTime ?? 1))
                                    ? AppColors.letterColor
                                    : AppColors.mainColor,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                (!isApplied) ? Strings.apply : "Applied",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
