import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Just for demo
const productDemoImg1 = 'https://i.imgur.com/CGCyp1d.png';
const productDemoImg2 = 'https://i.imgur.com/AkzWQuJ.png';
const productDemoImg3 = 'https://i.imgur.com/J7mGZ12.png';
const productDemoImg4 = 'https://i.imgur.com/q9oF9Yq.png';
const productDemoImg5 = 'https://i.imgur.com/MsppAcx.png';
const productDemoImg6 = 'https://i.imgur.com/JfyZlnO.png';

// End For demo

const grandisExtendedFont = 'Grandis Extended';

// On color 80, 60.... those means opacity

// App primary palette updated to gradient: #6441A5, #472575, #2A0845
const Color primaryColor = Color(0xFF6441A5);

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFF6441A5, <int, Color>{
  50: Color(0xFFEDE8F7),
  100: Color(0xFFD6CBEF),
  200: Color(0xFFB9A9E4),
  300: Color(0xFF9C87D9),
  400: Color(0xFF836CCF),
  500: Color(0xFF6441A5),
  600: Color(0xFF5A3996),
  700: Color(0xFF4E3187),
  800: Color(0xFF432A78),
  900: Color(0xFF2A0845),
});

// Primary gradient for brand surfaces
const LinearGradient appPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6441A5),
    Color(0xFF472575),
    Color(0xFF2A0845),
  ],
);

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);

// Test User Configuration (for development/testing only)
const bool enableTestUser = false; // DISABLED FOR PRODUCTION - Set to true for testing
const String testUserPhone = '9876543210';
const String testUserId = 'cmjjx4dyn255i07o92vexv4jl';
const String testUserName = 'Test User';
const double testUserWalletBalance = 10000.0;
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color appBackgroundColor = Color(0xFFF4F4F4);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

// Standard size names that don't require user selection
const List<String> standardFreeSizes = [
  'FREE_SIZE',
  'FREE SIZE',
  'ONE_SIZE',
  'ONE SIZE',
  'NO_SIZE',
  'NO SIZE',
  'FREESIZE',
  'ONESIZE',
  'NOSIZE',
  'FREE',
  'ONE',
];

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'passwords must have at least one special character',),
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Enter a valid email address'),
]);

const pasNotMatchErrorText = 'passwords do not match';
