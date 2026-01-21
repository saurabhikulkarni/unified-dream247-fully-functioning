import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

Widget customTextField(
  TextEditingController controller,
  String? hint,
  TextInputType keyboardType,
  int max,
  int? maxlines,
) {
  return customTextFieldReadOnly(
    controller,
    hint,
    keyboardType,
    max,
    true,
    maxlines ?? 1,
  );
}

Widget customTextFieldUppercase(
  TextEditingController controller,
  String? hint,
  TextInputType keyboardType,
  int max,
) {
  return customTextFieldReadOnlyUppercase(
    controller,
    hint,
    keyboardType,
    max,
    true,
  );
}

Widget customTextFieldReadOnly(
  TextEditingController controller,
  String? hint,
  TextInputType keyboardType,
  int max,
  bool readOnly,
  int? maxlines,
) {
  return TextField(
    controller: controller,
    enabled: readOnly,
    maxLines: maxlines,
    decoration: InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelText: hint,
      filled: true,
      counterText: '',
      fillColor: AppColors.transparent,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.greyColor, width: 0.25),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    ),
    style: const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 14,
      color: AppColors.letterColor,
    ),
    maxLength: (max != 0) ? max : 99,
    textAlign: TextAlign.justify,
    keyboardType: keyboardType,
  );
}

Widget customTextFieldReadOnlyUppercase(
  TextEditingController controller,
  String? hint,
  TextInputType keyboardType,
  int max,
  bool readOnly,
) {
  return TextField(
    controller: controller,
    enabled: readOnly,
    decoration: InputDecoration(
      labelText: hint,
      filled: true,
      counterText: '',
      fillColor: AppColors.transparent,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.editTextColor, width: 0.25),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    ),
    inputFormatters: [UpperCaseTextFormatter()],
    style: const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 12,
      color: AppColors.letterColor,
    ),
    maxLength: (max != 0) ? max : 99,
    textAlign: TextAlign.justify,
    keyboardType: keyboardType,
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PanCardInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String upperCaseValue = newValue.text.toUpperCase();

    if (!RegExp(r'^[A-Z]{0,5}[0-9]{0,4}[A-Z]{0,1}$').hasMatch(upperCaseValue)) {
      return oldValue;
    }

    return TextEditingValue(
      text: upperCaseValue,
      selection: TextSelection.collapsed(offset: upperCaseValue.length),
    );
  }
}
