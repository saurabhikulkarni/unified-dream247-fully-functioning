import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

class VerificationTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;

  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool? showPrefix;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  const VerificationTextField({
    super.key,
    this.labelText,
    this.controller,
    this.inputFormatters,
    this.keyboardType,
    this.showPrefix,
    this.maxLength,
    this.prefixIcon,
    this.margin,
    this.contentPadding,
    this.onChanged,
    this.hintText,
    this.readOnly = false,
    this.enabled = true,
  });

  @override
  State<VerificationTextField> createState() => _VerificationTextFieldState();
}

class _VerificationTextFieldState extends State<VerificationTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: widget.margin ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xfff5f5f5),
      ),
      child: TextFormField(
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        controller: widget.controller,
        cursorColor: AppColors.blackColor,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          counterText: '',
          prefixIcon: widget.prefixIcon,
          labelStyle: const TextStyle(color: AppColors.greyColor, fontSize: 12),
          labelText: widget.labelText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.greyColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFAFAFAF), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.mainColor, width: 2),
          ),
        ),
      ),
    );
  }
}
