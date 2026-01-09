import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';

class CustomTextfield extends StatefulWidget {
  final bool? readOnly;
  final String? labelText;
  final String? hintText;
  final TextStyle? style;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool? showPrefix;
  final int? maxLength;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;

  const CustomTextfield({
    super.key,
    this.readOnly,
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
    this.style,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldWidgetState();
}

class _CustomTextfieldWidgetState extends State<CustomTextfield> {
  bool _showClearIcon = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleTextChange);
    _showClearIcon = widget.controller?.text.isNotEmpty ?? false;
  }

  void _handleTextChange() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _showClearIcon) {
      setState(() {
        _showClearIcon = hasText;
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
      ),
      child: TextFormField(
        readOnly: widget.readOnly ?? false,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        controller: widget.controller,
        cursorColor: AppColors.blackColor,
        style: widget.style ??
            const TextStyle(color: AppColors.blackColor, fontSize: 16),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          prefixIcon: widget.prefixIcon,
          prefix: widget.showPrefix == true
              ? const Text(
                  '+91 ',
                  style: TextStyle(
                    color: Color(0xFF6a6767),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : const SizedBox.shrink(),
          suffixIcon: widget.readOnly == false
              ? _showClearIcon
                  ? InkWell(
                      onTap: () {
                        widget.controller?.clear();
                        setState(() => _showClearIcon = false);
                      },
                      child: const Icon(
                        IconData(0xef28, fontFamily: 'MaterialIcons'),
                        color: AppColors.greyColor,
                      ),
                    )
                  : null
              : null,
          labelStyle: const TextStyle(color: AppColors.lightGrey, fontSize: 14),
          labelText: widget.labelText,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: AppColors.lightGrey, fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lightGrey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lightGrey, width: 2),
          ),
        ),
      ),
    );
  }
}
