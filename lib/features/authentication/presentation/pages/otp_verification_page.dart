import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// OTP verification page
class OtpVerificationPage extends StatelessWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
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
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              phone: widget.phoneNumber,
              otp: _otpController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    const SizedBox(height: 40),
                    const Icon(
                      Icons.sms_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verify OTP',
                      style: TextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code sent to',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.phoneNumber,
                      style: TextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // OTP field
                    CustomTextField(
                      controller: _otpController,
                      labelText: 'OTP',
                      hintText: 'Enter 6-digit OTP',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: Validators.validateOtp,
                      enabled: !isLoading,
                      onSubmitted: (_) => _onVerifyPressed(),
                    ),
                    const SizedBox(height: 24),
                    // Verify button
                    CustomButton(
                      text: 'Verify',
                      onPressed: isLoading ? null : _onVerifyPressed,
                      isLoading: isLoading,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    // Resend OTP
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              // TODO: Implement resend OTP
                            },
                      child: const Text('Resend OTP'),
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
}
