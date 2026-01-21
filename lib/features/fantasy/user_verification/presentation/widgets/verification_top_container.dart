import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';

class VerificationTopContainer extends StatelessWidget {
  const VerificationTopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        Center(
            child: CircleAvatar(
                radius: 42,
                child: Image.asset(
                  Images.verificationIcon,
                ),),),
        const SizedBox(
          height: 8,
        ),
        const Center(
          child: Text(
            Strings.verifySteps,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.letterColor,),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
                text: const TextSpan(
                    text: 'Let’s ensure you’re ',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.letterColor,),
                    children: [
                  TextSpan(
                    text: '18+ ',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.letterColor,),
                  ),
                  // TextSpan(
                  //   text: "& not from a ",
                  //   style: TextStyle(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w400,
                  //       color: AppColors.letterColor),
                  // ),
                  // TextSpan(
                  //   text: "restricted state",
                  //   style: TextStyle(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w700,
                  //       color: AppColors.letterColor),
                  // )
                ],),),
            // const SizedBox(
            //   width: 12,
            // ),
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.letterColor,
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          width: 225,
          margin: const EdgeInsets.all(12),
          height: 36,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.mainColor.withAlpha(70),),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: AppColors.mainColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  Strings.millionsAlreadyVerified,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,),
                ),
              ),
              Icon(
                Icons.star,
                size: 12,
                color: AppColors.mainColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
