import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// OTP verification page with MSG91 integration
class OtpVerificationPage extends StatelessWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<AuthBloc>();
        // Send OTP when page loads
        bloc.add(SendOtpEvent(phone: phoneNumber));
        return bloc;
      },
      child: _OtpVerificationView(phoneNumber: phoneNumber),
    );
  }
}

class _OtpVerificationView extends StatefulWidget {
  final String phoneNumber;

  const _OtpVerificationView({required this.phoneNumber});

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  final _formKey = GlobalKey<FormState>();
  String _otp = '';
  bool _isOtpComplete = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
          }
        });
        return _resendTimer > 0;
      }
      return false;
    });
  }

  void _onVerifyPressed() {
    if (_otp.length == 6) {
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              phone: widget.phoneNumber,
              otp: _otp,
            ),
          );
    }
  }

  void _onResendOtp() {
    if (_canResend) {
      context.read<AuthBloc>().add(SendOtpEvent(phone: widget.phoneNumber));
      setState(() {
        _resendTimer = 60;
        _canResend = false;
      });
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(RouteNames.login),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(RouteNames.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is OtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // SMS icon with gradient background
                    Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6441A5),
                            const Color(0xFF472575),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6441A5).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sms_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'Verify OTP',
                      style: TextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Enter the 6-digit code sent to',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      _formatPhoneNumber(widget.phoneNumber),
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // PIN code field
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 45,
                        activeFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                        activeColor: AppColors.primary,
                        selectedColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      backgroundColor: Colors.transparent,
                      enableActiveFill: true,
                      keyboardType: TextInputType.number,
                      onCompleted: (value) {
                        setState(() {
                          _otp = value;
                          _isOtpComplete = true;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          _otp = value;
                          _isOtpComplete = value.length == 6;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Verify button
                    CustomButton(
                      text: 'Verify & Continue',
                      onPressed: (isLoading || !_isOtpComplete) 
                          ? null 
                          : _onVerifyPressed,
                      isLoading: isLoading,
                      width: double.infinity,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Resend OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive OTP? ',
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_canResend)
                          TextButton(
                            onPressed: isLoading ? null : _onResendOtp,
                            child: const Text('Resend OTP'),
                          )
                        else
                          Text(
                            'Resend in $_resendTimer s',
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    // Format: +91 XXXXX XXXXX
    if (phone.length >= 12) {
      return '+${phone.substring(0, 2)} ${phone.substring(2, 7)} ${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }
}
