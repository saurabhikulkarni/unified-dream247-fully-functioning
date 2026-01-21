// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_widgets.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/verification_textfield.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/user_verification/data/models/kyc_detail_model.dart';
import 'package:unified_dream247/features/fantasy/user_verification/data/verification_datasource.dart';
import 'package:unified_dream247/features/fantasy/user_verification/domain/use_cases/verification_usecases.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/providers/kyc_details_provider.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/widgets/verification_border_widget.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/widgets/verification_shimmer_widget.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/widgets/verification_top_container.dart';

class VerifyDetailsPage extends StatefulWidget {
  const VerifyDetailsPage({super.key});

  @override
  State<VerifyDetailsPage> createState() => _VerifyDetailsPageState();
}

class _VerifyDetailsPageState extends State<VerifyDetailsPage> {
  String? email;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController _aadhaarNumber = TextEditingController();
  final TextEditingController _panCardController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  VerificationUsecases verificationUsecases = VerificationUsecases(
    VerificationDatasource(ApiImplWithAccessToken()),
  );
  KycDetailsModel? kycDetailsModel;
  bool? isAadharenabled = false;
  bool? isPanEnabled = false;
  bool? isBankEnabled = false;
  bool _isPanDetailsVisible = false;
  bool _isAadharDetailsVisible = false;
  bool _isBankDetailsVisible = false;
  bool _isLoading = true;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String _otpMessage = '';

  Future<void> googlelogin() async {
    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      email = userCredential.user?.email;

      final String token = googleAuth.accessToken ?? '';

      validateEmail(token);
    } catch (e) {
      debugPrint('GOOGLE LOGIN ERROR => $e');
      appToast('Google Sign-In failed', context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<dynamic> googlelogin() async {
  //   try {
  //     await GoogleSignIn().signOut();
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser?.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );
  //     final UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     final String token = userCredential.credential?.accessToken ?? "";
  //     email = userCredential.user?.email;

  //     validateEmail(token);
  //     return userCredential;
  //   } catch (e) {
  //     debugPrint('exception->$e');
  //   }
  // }

  void validateEmail(String token) async {
    // String deviceId = await AppUtils.getDeviceId(context);

    verificationUsecases.socialLogin(context, token, '').then((value) {
      if (value == true) {
        Provider.of<KycDetailsProvider>(context, listen: false)
            .kycData
            ?.emailVerify = 1;
        Provider.of<KycDetailsProvider>(context, listen: false).kycData?.email =
            email;
        setState(() {
          loadKycData();
        });
      }
    });
  }

  // void submitAadharDetails() {
  //   verificationUsecases.submitAadharDetails(context, _aadhaarNumber.text).then(
  //     (value) {
  //       if (value != null) {
  //         if (value['status'] == true) {
  //           // AppNavigation.gotoVerifyOtpScreen(
  //           //         context,
  //           //         "",
  //           //         value['ref_id'],
  //           //         'Aadhaar',
  //           //         _aadhaarNumber.text,
  //           //         'AADHAAR VERIFICATION',
  //           //         'We Have Sent an OTP to Register Mobile Number')
  //           //     .then((value) => {
  //           //           debugPrint(value),
  //           //           if (value == '1')
  //           //             {
  //           //               setState(() {
  //           //                 Provider.of<KycDetailsProvider>(context,
  //           //                         listen: false)
  //           //                     .kycData
  //           //                     ?.aadharVerify = 1;
  //           //                 loadKycData();
  //           //               })
  //           //             }
  //           //         });
  //         }
  //       }
  //     },
  //   );
  // }
  void submitAadharDetails() async {
    setState(() {
      _isSendingOtp = true;
    });

    final res = await verificationUsecases.submitAadharDetails(
      context,
      _aadhaarNumber.text,
    );

    setState(() {
      _isSendingOtp = false;
    });

    if (res != null && res['success'] == true) {
      final refId = res['data']?['data']?['reference_id']?.toString();
      if (refId != null && refId.isNotEmpty) {
        _showAadhaarOtpDialog(refId);
      } else {
        appToast('Reference Id missing from server', context);
      }
    } else {
      appToast(res?['message'] ?? 'Failed to send Aadhaar OTP', context);
    }
  }

  Future<bool> _verifyAadhaarOtp(String refId, String otp) async {
    final res = await verificationUsecases.verifyAadharOtp(
      context,
      refId,
      otp,
      _aadhaarNumber.text,
    );

    if (res == true) {
      Provider.of<KycDetailsProvider>(context, listen: false)
          .kycData
          ?.aadharVerify = 1;

      loadKycData();
      return true;
    }
    return false;
  }

  void _showAadhaarOtpDialog(String refId) {
    TextEditingController otpCtrl = TextEditingController();
    _isVerifyingOtp = false;
    _otpMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),),
              title: const Text('Verify Aadhaar OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter OTP sent to registered mobile number'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: otpCtrl,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: 'Enter OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),),
                  ),
                  if (_otpMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _otpMessage,
                      style: TextStyle(
                        color: _otpMessage.contains('success')
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (_isVerifyingOtp) ...[
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isVerifyingOtp ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isVerifyingOtp
                      ? null
                      : () async {
                          if (otpCtrl.text.length != 6) return;

                          setDialogState(() {
                            _isVerifyingOtp = true;
                            _otpMessage = 'Verifying OTP...';
                          });

                          final success =
                              await _verifyAadhaarOtp(refId, otpCtrl.text);

                          setDialogState(() {
                            _isVerifyingOtp = false;
                            _otpMessage = success
                                ? 'Aadhaar verified successfully'
                                : 'Invalid OTP. Please try again.';
                          });

                          if (success) {
                            await Future.delayed(
                                const Duration(milliseconds: 700),);
                            if (mounted) Navigator.pop(context);
                          }
                        },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void _showAadhaarOtpDialog(String refId) {
  //   TextEditingController otpCtrl = TextEditingController();

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       title: const Text("Verify Aadhaar OTP"),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text("Enter OTP sent to Aadhaar registered mobile number"),
  //           const SizedBox(height: 10),
  //           TextField(
  //             controller: otpCtrl,
  //             maxLength: 6,
  //             keyboardType: TextInputType.number,
  //             decoration: const InputDecoration(hintText: "Enter OTP"),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             if (otpCtrl.text.length == 6) {
  //               Navigator.pop(context);
  //               _verifyAadhaarOtp(refId, otpCtrl.text);
  //             }
  //           },
  //           child: const Text("Verify"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void submitPanDetails() {
    verificationUsecases
        .submitPANDetails(
      context,
      _panCardController.text.toUpperCase(),
      Provider.of<UserDataProvider>(
            context,
            listen: false,
          ).userData?.name ??
          '',
    )
        .then((value) {
      if (value == true) {
        Provider.of<KycDetailsProvider>(context, listen: false)
            .kycData
            ?.panVerify = 1;
        Provider.of<KycDetailsProvider>(context, listen: false)
            .panVerifiedStatus
            .value = 1;
        setState(() {
          loadKycData();
        });
      }
    });
  }

  void submitBankDetails() {
    verificationUsecases
        .submitBankDetails(
      context,
      accountHolderController.text,
      _accountNumberController.text,
      _ifscController.text,
      cityNameController.text,
      bankNameController.text,
    )
        .then((value) {
      if (value == true) {
        Provider.of<KycDetailsProvider>(context, listen: false)
            .kycData!
            .bankVerify = 1;
        Provider.of<KycDetailsProvider>(context, listen: false)
            .bankVerifiedStatus
            .value = 1;
        Provider.of<WalletDetailsProvider>(context, listen: false)
            .walletData
            ?.allverify = 1;
        setState(() {
          loadKycData();
        });
      }
    });
  }

  bool aadharValid() {
    bool valid = true;

    if (!AppUtils.isValidAadhaarCardNumber(_aadhaarNumber.text)) {
      valid = false;
      appToast('Please enter valid aadhaar card number', context);
    }

    return valid;
  }

  bool panValid() {
    bool valid = true;

    if (!AppUtils.isValidPANNumber(_panCardController.text)) {
      valid = false;
      appToast('Please enter valid pan card number', context);
    }

    return valid;
  }

  bool bankValid() {
    bool valid = true;

    if (!AppUtils.isValidName(_nameController.text)) {
      valid = false;
      appToast('Please enter valid name', context);
      return valid;
    }

    if (!AppUtils.isValidAccountNumber(_accountNumberController.text)) {
      valid = false;
      appToast('Please enter valid account number', context);
    }

    if (!AppUtils.isValidIfscCode(_ifscController.text)) {
      valid = false;
      appToast('Please enter valid ifsc code', context);
    }
    if (cityNameController.text.isEmpty || cityNameController.text == '') {
      valid = false;
      appToast('Please enter city name', context);
    }

    if (bankNameController.text.isEmpty || bankNameController.text == '') {
      valid = false;
      appToast('Please enter Bank name', context);
    }

    return valid;
  }

  void loadKycData() async {
    setState(() {
      _isLoading = true;
    });
    final kycData =
        Provider.of<KycDetailsProvider>(context, listen: false).kycData;
    if (kycData?.aadharcard == null ||
        kycData?.bank == null ||
        kycData?.pancard == null ||
        kycData?.email == null ||
        kycData?.mobile == null) {
      kycDetailsModel = await verificationUsecases.getKycDetails(context);
    } else {
      kycDetailsModel = kycData;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildAadhaarSection(KycDetailsModel? kycData) {
    if (kycData?.aadharVerify == 1) {
      return detailsVerified(
        Images.aadhaarCard,
        Strings.aadharVerified,
        AppUtils.maskDigits(
          kycDetailsModel?.aadharcard?.aadharNumber ?? '---',
          4,
        ),
        true,
      );
    }

    if (kycData?.emailVerify == 1 && kycData?.mobileVerify == 1) {
      return verifyAadhaar();
    }

    return transparentWidget(
      Images.aadhaarCard,
      Strings.step2,
      Strings.verifyAadhaarCard,
      true,
    );
  }

  Widget buildPanSection(KycDetailsModel? kycData) {
    if (kycData?.panVerify == 1) {
      return detailsVerified(
        Images.panCard,
        Strings.panVerified,
        AppUtils.maskDigits(
          kycDetailsModel?.pancard?.panNumber ?? '---',
          2,
        ),
        true,
      );
    }

    if (kycData?.aadharVerify == 1) {
      return verifyPanCard();
    }

    return transparentWidget(
      Images.panCard,
      Strings.step3,
      Strings.verifyPanCard,
      true,
    );
  }

  Widget buildBankSection(KycDetailsModel? kycData) {
    if (kycData?.bankVerify == 1) {
      return detailsVerified(
        Images.icBank,
        Strings.bankVerified,
        AppUtils.maskDigits(
          kycDetailsModel?.bank?.accno ?? '---',
          4,
        ),
        true,
      );
    }

    if (kycData?.panVerify == 1) {
      return verifyBank();
    }

    return transparentWidget(
      Images.icBank,
      Strings.step4,
      Strings.verifyBankAccount,
      true,
    );
  }

  @override
  void initState() {
    super.initState();
    loadKycData();
    // final kycData =
    //     Provider.of<KycDetailsProvider>(context, listen: false).kycData;

    // if (kycData?.panVerify != -1 ||
    //     kycData?.aadharVerify != -1 ||
    //     kycData?.bankVerify != -1) {
    //   loadKycData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final kycData =
        Provider.of<KycDetailsProvider>(context, listen: true).kycData;
    _nameController.text = kycDetailsModel?.aadharcard?.aadharName ?? '';
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.verifyDetails,
      addPadding: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const VerificationTopContainer(),
            _isLoading
                ? const Column(
                    children: [
                      VerificationShimmerWidget(image: Images.icGoogle),
                      VerificationShimmerWidget(image: Images.aadhaarCard),
                      VerificationShimmerWidget(image: Images.panCard),
                      VerificationShimmerWidget(image: Images.icBank),
                    ],
                  )
                : Column(
                    children: [
                      (kycData?.emailVerify != 1)
                          ? GestureDetector(
                              onTap: () => googlelogin(),
                              child: transparentWidget(
                                Images.icGoogle,
                                Strings.step1,
                                Strings.verifyGoogle,
                                false,
                              ),
                            )
                          : detailsVerified(
                              Images.icGoogle,
                              Strings.emailVerified,
                              kycData?.email ?? '',
                              false,
                            ),
                      // Visibility(
                      //   visible: (kycData?.emailVerify != 1 ||
                      //       kycData?.mobileVerify != 1),
                      //   child: transparentWidget(
                      //     Images.aadhaarCard,
                      //     Strings.step2,
                      //     Strings.verifyAadhaarCard,
                      //     true,
                      //   ),
                      // ),
                      // Visibility(
                      //   visible: (kycData?.emailVerify == 1 &&
                      //       kycData?.mobileVerify == 1 &&
                      //       (kycData?.aadharVerify == -1 ||
                      //           kycData?.aadharVerify == 2)),
                      //   child: verifyAadhaar(),
                      // ),
                      // Visibility(
                      //   visible: (kycData?.aadharVerify == 1),
                      //   child: detailsVerified(
                      //     Images.aadhaarCard,
                      //     Strings.aadharVerified,
                      //     AppUtils.maskDigits(
                      //       kycDetailsModel?.aadharcard?.aadharNumber ?? "---",
                      //       4,
                      //     ),
                      //     true,
                      //   ),
                      // ),
                      buildAadhaarSection(kycData),
                      // Visibility(
                      //   visible: (kycData?.emailVerify != 1 ||
                      //       kycData?.mobileVerify != 1 ||
                      //       kycData?.aadharVerify != 1),
                      //   child: transparentWidget(
                      //     Images.panCard,
                      //     Strings.step3,
                      //     Strings.verifyPanCard,
                      //     true,
                      //   ),
                      // ),
                      // Visibility(
                      //   visible: kycData?.panVerify == -1 &&
                      //       kycData?.aadharVerify == 1,
                      //   child: verifyPanCard(),
                      // ),
                      // Visibility(
                      //   visible: kycData?.panVerify == 1,
                      //   child: detailsVerified(
                      //     Images.panCard,
                      //     Strings.panVerified,
                      //     AppUtils.maskDigits(
                      //       kycDetailsModel?.pancard?.panNumber ?? "---",
                      //       2,
                      //     ),
                      //     true,
                      //   ),
                      // ),
                      buildPanSection(kycData),
                      // Visibility(
                      //   visible: (kycData?.panVerify == -1 ||
                      //       kycData?.aadharVerify == -1),
                      //   child: transparentWidget(
                      //     Images.icBank,
                      //     Strings.step4,
                      //     Strings.verifyBankAccount,
                      //     true,
                      //   ),
                      // ),
                      // Visibility(
                      //   visible: (kycData?.bankVerify == -1 ||
                      //           kycData?.bankVerify == 2) &&
                      //       kycData?.panVerify == 1,
                      //   child: verifyBank(),
                      // ),
                      // Visibility(
                      //   visible: (kycData?.bankVerify == 1),
                      //   child: detailsVerified(
                      //     Images.icBank,
                      //     Strings.bankVerified,
                      //     AppUtils.maskDigits(
                      //       kycDetailsModel?.bank?.accno ?? "---",
                      //       4,
                      //     ),
                      //     true,
                      //   ),
                      // ),
                      buildBankSection(kycData),
                    ],
                  ),
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.only(bottom: 30.0, left: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.letterColor,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.letterColor,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "Any details once submitted can't be unlinked and used for any other account.",
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.letterColor,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'It can take 5 minutes to verify your details, so wait.',
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.letterColor,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'Your name mentioned on Bank, should match all for complete verification.',
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.letterColor,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'You will get 3 chances in a day with frequency of 5 minutes each for completing KYC, so use right details and carefully.',
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget verifyEmail() {
    return VerificationBorderWidget(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SvgPicture.asset(Images.icGoogle, height: 40, width: 40),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.step1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.letterColor,
                ),
              ),
              Text(
                Strings.verifyGoogle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.letterColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget detailsVerified(
    String image,
    String step,
    String verifiedType,
    bool? details,
  ) {
    return GestureDetector(
      onTap: () {
        if (image == Images.aadhaarCard) {
          _isAadharDetailsVisible = !_isAadharDetailsVisible;
        } else if (image == Images.panCard) {
          _isPanDetailsVisible = !_isPanDetailsVisible;
        } else if (image == Images.icBank) {
          _isBankDetailsVisible = !_isBankDetailsVisible;
        }
        setState(() {});
      },
      child: VerificationBorderWidget(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(image, height: 40, width: 40),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainColor,
                      ),
                    ),
                    Text(
                      verifiedType,
                      style: GoogleFonts.exo2(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Image.asset(Images.verified, height: 24, width: 24),
              ],
            ),
            if (_isAadharDetailsVisible &&
                details == true &&
                image == Images.aadhaarCard)
              aadharDetails(),
            if (_isPanDetailsVisible &&
                details == true &&
                image == Images.panCard)
              panDetails(),
            if (_isBankDetailsVisible &&
                details == true &&
                image == Images.icBank)
              bankDetails(),
          ],
        ),
      ),
    );
  }

  Widget verifyAadhaar() {
    return VerificationBorderWidget(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(Images.aadhaarCard, height: 40, width: 40),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.step2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.letterColor,
                    ),
                  ),
                  Text(
                    Strings.enterYourAadharDetails,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.letterColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          VerificationTextField(
            maxLength: 12,
            showPrefix: true,
            keyboardType: TextInputType.number,
            controller: _aadhaarNumber,
            labelText: Strings.enterAadhaarNumber,
            hintText: Strings.enterAadhaarNumber,
            onChanged: (p0) {
              setState(() {
                isAadharenabled = true;
              });
            },
          ),
          const SizedBox(height: 10),
          MainButton(
            onTap: _isSendingOtp
                ? null
                : () {
                    if (aadharValid()) {
                      submitAadharDetails();
                    }
                  },
            color: isAadharenabled == true
                ? AppColors.mainColor
                : AppColors.whiteFade1,
            textColor: AppColors.white,
            text: _isSendingOtp
                ? 'SENDING OTP...'
                : Strings.verifyAadhaarCard.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget verifyPanCard() {
    return VerificationBorderWidget(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(Images.panCard, height: 40, width: 40),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.step3,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.letterColor,
                    ),
                  ),
                  Text(
                    Strings.enterYourPanCardDetails,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.letterColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          VerificationTextField(
            inputFormatters: [UpperCaseTextFormatter()],
            maxLength: 10,
            showPrefix: true,
            keyboardType: TextInputType.text,
            controller: _panCardController,
            labelText: Strings.enterYourPanCardDetails,
            hintText: Strings.enterYourPanCardDetails,
            onChanged: (p0) {
              setState(() {
                isPanEnabled = true;
              });
            },
          ),
          const SizedBox(height: 10),
          MainButton(
            onTap: () {
              if (panValid()) {
                submitPanDetails();
              }
            },
            color: isPanEnabled == true
                ? AppColors.mainColor
                : AppColors.whiteFade1,
            textColor:
                isPanEnabled == true ? AppColors.white : AppColors.lightGrey,
            text: Strings.verifyPanCard.toUpperCase(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget verifyBank() {
    return VerificationBorderWidget(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(Images.icBank, height: 40, width: 40),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   Strings.step4,
                  //   style: TextStyle(
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.w400,
                  //     color: AppColors.letterColor,
                  //   ),
                  // ),
                  Text(
                    Strings.enterYourBankDetails,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.letterColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          VerificationTextField(
            showPrefix: true,
            keyboardType: TextInputType.name,
            controller: accountHolderController,
            labelText: 'Enter AccountHolder Name',
            readOnly: false,
            enabled: true,
          ),
          VerificationTextField(
            showPrefix: true,
            keyboardType: TextInputType.number,
            controller: _accountNumberController,
            maxLength: 20,
            labelText: Strings.enterAccountNumber,
            hintText: Strings.enterAccountNumber,
            onChanged: (p0) {
              if (_accountNumberController.text != '' &&
                  _ifscController.text != '') {
                setState(() {
                  isBankEnabled = true;
                });
              }
            },
          ),
          VerificationTextField(
            showPrefix: true,
            maxLength: 11,
            keyboardType: TextInputType.text,
            controller: _ifscController,
            labelText: Strings.enterIfscCode,
            hintText: Strings.enterIfscCode,
            onChanged: (p0) {
              String formattedText = p0.toUpperCase();
              if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(formattedText) &&
                  formattedText.length == 11) {
                return;
              }

              _ifscController.value = _ifscController.value.copyWith(
                text: formattedText,
                selection: TextSelection.collapsed(
                  offset: formattedText.length,
                ),
              );

              if (_accountNumberController.text.isNotEmpty &&
                  _ifscController.text.isNotEmpty) {
                setState(() {
                  isBankEnabled = true;
                });
              }
            },
          ),
          VerificationTextField(
            showPrefix: true,
            controller: bankNameController,
            maxLength: 20,
            labelText: 'Enter Bank Name',
            hintText: 'Enter Bank Name',
            onChanged: (p0) {
              if (_accountNumberController.text != '' &&
                  _ifscController.text != '') {
                setState(() {
                  isBankEnabled = true;
                });
              }
            },
          ),
          VerificationTextField(
            showPrefix: true,
            controller: cityNameController,
            maxLength: 20,
            labelText: 'Enter City',
            hintText: 'Enter City Name',
            onChanged: (p0) {
              if (_accountNumberController.text != '' &&
                  _ifscController.text != '') {
                setState(() {
                  isBankEnabled = true;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          MainButton(
            onTap: () {
              if (bankValid()) {
                submitBankDetails();
              }
            },
            color: isBankEnabled == true
                ? AppColors.mainColor
                : AppColors.whiteFade1,
            textColor:
                isBankEnabled == true ? AppColors.white : AppColors.lightGrey,
            text: Strings.verifyBankAccount.toUpperCase(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget transparentWidget(String img, String step, String type, bool? color) {
    return Stack(
      children: [
        VerificationBorderWidget(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.whiteFade1,
                child: SvgPicture.asset(img, height: 24, width: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.letterColor,
                    ),
                  ),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.letterColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              color: (color == true)
                  ? AppColors.white.withAlpha(70)
                  : AppColors.white.withAlpha(0),
            ),
          ),
        ),
      ],
    );
  }

  Widget aadharDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                    child: Text(
                      'Aadhaar Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      kycDetailsModel?.aadharcard?.aadharName ?? '--',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                    child: Text(
                      'Aadhaar Number',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      kycDetailsModel?.aadharcard?.aadharNumber ?? '--',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                    child: Text(
                      'Aadhaar DOB',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      kycDetailsModel?.aadharcard?.aadharDob ?? '--',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                    child: Text(
                      'Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 3,
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        kycDetailsModel?.aadharcard?.address ?? '--',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.letterColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                    child: Text(
                      'Gender',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      kycDetailsModel?.aadharcard?.gender ?? '--',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget panDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                    child: Text(
                      'PAN Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      kycDetailsModel?.pancard?.panName ?? '',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                    child: Text(
                      'PAN Number',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      kycDetailsModel?.pancard?.panNumber ?? '',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget bankDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  'User Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  kycDetailsModel?.bank?.accountholder ?? '',
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  'Account Number',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  kycDetailsModel?.bank?.accno ?? '',
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  'IFSC Code',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  kycDetailsModel?.bank?.ifsc ?? '',
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  'Address',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  kycDetailsModel?.bank?.city ?? '',
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  'Bank Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  kycDetailsModel?.bank?.bankname ?? '',
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  'Branch Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
                child: Text(
                  kycDetailsModel?.bank?.bankbranch ?? '',
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
