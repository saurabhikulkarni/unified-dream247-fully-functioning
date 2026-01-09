import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/features/onboarding/presentation/controllers/login_controller.dart';

// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});

//   final LoginController controller = Get.put(LoginController());

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         resizeToAvoidBottomInset: true,
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.015),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         if (Platform.isAndroid) {
//                           SystemNavigator.pop();
//                         } else if (Platform.isIOS) {
//                           exit(0);
//                         }
//                       },
//                       child: const Icon(
//                         Icons.arrow_back_ios_new,
//                         size: 20,
//                         color: AppColors.letterColor,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           Strings.loginRegister,
//                           style: TextStyle(
//                             color: AppColors.letterColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           Strings.letGetStarted,
//                           style: TextStyle(
//                             color: AppColors.letterColor,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 5),
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: AppColors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(15),
//                       topRight: Radius.circular(15),
//                     ),
//                   ),
//                   child: Obx(
//                     () => SingleChildScrollView(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CustomTextfield(
//                             maxLength: 10,
//                             showPrefix: true,
//                             keyboardType: TextInputType.number,
//                             controller: controller.loginController,
//                             labelText: 'Mobile number',
//                             hintText: "10 digit mobile number",
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                           ),
//                           if (controller.showReferralField.value)
//                             CustomTextfield(
//                               controller: controller.referralCodeController,
//                               labelText: 'Referral Code',
//                               hintText: 'Enter referral code',
//                               readOnly: controller.readOnly.value,
//                               maxLength: 15,
//                             ),
//                           if (controller.showReferralField.value)
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 const Text(
//                                   'Have a Refer Code?',
//                                   style: TextStyle(
//                                     color: AppColors.mainColor,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 Transform.scale(
//                                   scale: 0.7,
//                                   child: CupertinoSwitch(
//                                     value: controller.showReferralField.value,
//                                     activeTrackColor: AppColors.mainColor,
//                                     onChanged:
//                                         (value) =>
//                                             controller.toggleReferralField(),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           Row(
//                             children: [
//                               Obx(
//                                 () => Checkbox(
//                                   value: controller.isChecked.value,
//                                   onChanged: controller.toggleCheckbox,
//                                   activeColor: AppColors.mainColor,
//                                   checkColor: AppColors.white,
//                                 ),
//                               ),
//                               const Text(
//                                 'I Certify that I am above 18 years',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppColors.letterColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 15),
//                           Obx(
//                             () => MainButton(
//                               text: Strings.continuee.toUpperCase(),
//                               isLoading: controller.isLoading.value,
//                               color:
//                                   controller.isChecked.value
//                                       ? AppColors.mainColor
//                                       : AppColors.whiteFade1,
//                               textColor:
//                                   controller.isChecked.value
//                                       ? AppColors.white
//                                       : AppColors.greyColor,
//                               onTap: () => controller.continueToOtp(context),
//                             ),
//                           ),

//                           const SizedBox(height: 20),
//                           Center(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10.0,
//                               ),
//                               child: Wrap(
//                                 alignment: WrapAlignment.center,
//                                 children: [
//                                   const Text(
//                                     "By continuing, I accept the ",
//                                     style: TextStyle(
//                                       color: AppColors.letterColor,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: () {},
//                                     child: Column(
//                                       children: [
//                                         const Text(
//                                           "Terms of Service",
//                                           style: TextStyle(
//                                             color: AppColors.letterColor,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                         Container(
//                                           height: 1.5,
//                                           width: 90,
//                                           color: AppColors.letterColor,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const Text(
//                                     " and ",
//                                     style: TextStyle(
//                                       color: AppColors.letterColor,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: () {},
//                                     child: Column(
//                                       children: [
//                                         const Text(
//                                           "Privacy Policy",
//                                           style: TextStyle(
//                                             color: AppColors.letterColor,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                         Container(
//                                           height: 1.5,
//                                           width: 76,
//                                           color: AppColors.letterColor,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                           if (!controller.showReferralField.value)
//                             Center(
//                               child: InkWell(
//                                 onTap: controller.toggleReferralField,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(left: 10),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'Have a Refer Code?',
//                                         style: TextStyle(
//                                           color: AppColors.mainColor,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       Container(
//                                         height: 1.5,
//                                         width: 125,
//                                         color: AppColors.mainColor,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return controller.isOtpScreen.value
          ? buildOtpView(context)
          : buildLoginView(context);
    });
  }

  // ------------------------ LOGIN VIEW ------------------------
  Widget buildLoginView(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Login / Register",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.letterColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Let's get started!",
                  style: TextStyle(fontSize: 14, color: AppColors.greyColor),
                ),
                const SizedBox(height: 30),

                TextField(
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  controller: controller.loginController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    hintText: "10 digit mobile number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 12),

                Obx(() {
                  if (controller.showReferralField.value) {
                    return TextField(
                      controller: controller.referralCodeController,
                      decoration: InputDecoration(
                        labelText: "Referral Code",
                        hintText: "Enter referral code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () => controller.showReferralField.value = true,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          "Have a referral code?",
                          style: TextStyle(
                            color: AppColors.mainColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                }),

                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.isChecked.value,
                        onChanged: (v) =>
                            controller.isChecked.value = v ?? false,
                        activeColor: AppColors.mainColor,
                      ),
                    ),
                    const Text(
                      "I certify that I am above 18 years",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Continue Button
                Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: controller.isChecked.value
                          ? AppColors.mainColor
                          : AppColors.whiteFade1,
                    ),
                    onPressed: controller.isChecked.value
                        ? () => controller.continueToOtp(context)
                        : null,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            color: AppColors.white,
                          )
                        : const Text(
                            "CONTINUE",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "By continuing, I accept the Terms of Service and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.greyColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------ OTP VIEW ------------------------
  Widget buildOtpView(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Row(
                  children: [
                    InkWell(
                      onTap: () => controller.isOtpScreen.value = false,
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Almost there!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Enter the OTP sent to ${controller.loginController.text}",
                  style: const TextStyle(color: AppColors.greyColor),
                ),
                const SizedBox(height: 30),

                OTPTextField(
                  controller: controller.otpController,
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 45,
                  style: const TextStyle(fontSize: 17),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                  otpFieldStyle: OtpFieldStyle(
                    enabledBorderColor: AppColors.greyColor,
                    focusBorderColor: AppColors.mainColor,
                  ),
                  onChanged: (value) => {},
                  onCompleted: (otp) => controller.verifyOtp(otp),
                ),

                const SizedBox(height: 40),

                Obx(
                  () => Text(
                    controller.isResendEnabled.value
                        ? "Didn't receive OTP?"
                        : "Resend available in ${controller.remainingSeconds}s",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 6),

                Obx(
                  () => GestureDetector(
                    onTap: controller.isResendEnabled.value
                        ? controller.resendOtp
                        : null,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: controller.isResendEnabled.value
                            ? AppColors.mainColor
                            : AppColors.greyColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
