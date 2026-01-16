// ignore_for_file: use_build_context_synchronously

import 'dart:io';

// import 'package:apk_installer/apk_installer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:timer_builder/timer_builder.dart';

typedef TimerExpiredCallback = void Function();

class AppUtils {
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static ValueNotifier<int> teamsCount = ValueNotifier<int>(0);
  static ValueNotifier<int> contestCount = ValueNotifier<int>(0);
  static ValueNotifier<bool> isSelected = ValueNotifier<bool>(false);

  static bool isValidMobileNumber(String number) {
    RegExp pattern = RegExp(r'(0/91)?[6-9][0-9]{9}');
    return pattern.hasMatch(number);
  }

  static bool isValidPincode(String number) {
    RegExp pattern = RegExp(r'[1-9][0-9]{5}');
    return pattern.hasMatch(number);
  }

  static bool isValidAadhaarCardNumber(String number) {
    RegExp pattern = RegExp(r'[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}');
    return pattern.hasMatch(number);
  }

  static bool isValidPANNumber(String number) {
    RegExp pattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    return pattern.hasMatch(number);
  }

  static bool isValidTeamName(String name) {
    RegExp teamNamePattern = RegExp(
      r'^(?!ibest|ibest$)[a-zA-Z0-9@#$_&+\-%£¢€¥₹]{1,10}$',
      caseSensitive: false,
    );

    String emojiPattern = r'[^\x00-\x7F]+';
    RegExp emojiRegExp = RegExp(emojiPattern);

    return teamNamePattern.hasMatch(name) && !emojiRegExp.hasMatch(name);
  }

  static bool isValidName(String name) {
    RegExp pattern = RegExp(r'([a-zA-Z]{3,30}\s*)+');
    return pattern.hasMatch(name);
  }

  static bool isValidAddress(String address) {
    RegExp pattern = RegExp(r'([a-zA-Z]{3,300}\s*)+');
    return pattern.hasMatch(address);
  }

  static bool isValidEmailAddress(String email) {
    RegExp pattern = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-z]{2,4})$',
    );
    return pattern.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length > 3;
    // return RegExp(r'^(?=.*?[A-Za-z])(?=.*?[0-9]).{8,}$').hasMatch(password);
  }

  static bool isValidAccountNumber(String number) {
    RegExp pattern = RegExp(r'^[0-9]{6,18}$');
    return pattern.hasMatch(number);
  }

  static bool isValidIfscCode(String code) {
    RegExp pattern = RegExp(r'^[A-Za-z]{4}[0]{1}[A-Za-z0-9]{6}');
    return pattern.hasMatch(code);
  }

  static String formatDateTime(String date) {
    DateTime newDate = DateTime.parse(date);
    String formattedDate = DateFormat('MMM dd, yyyy HH:mm a').format(newDate);
    return formattedDate;
  }

  static String formatDate(String date) {
    DateTime newDate = DateTime.parse(date);
    String formattedDate = DateFormat('MMM dd, yyyy').format(newDate);
    return formattedDate;
  }

  static String formatTime(String date) {
    DateTime newDate = DateTime.parse(date);
    String formattedDate = DateFormat('hh:mm a').format(newDate);
    String formattedDate1 = DateFormat(' hh:mm a').format(newDate);
    DateTime now = DateTime.now();
    if (newDate.year == now.year &&
        newDate.month == now.month &&
        newDate.day == now.day) {
      return 'Today , $formattedDate';
    }
    return formattedDate1;
  }

  static String formatCustomDate(String dateString) {
    // 2024/12/12 14:44
    List<String> components = dateString.split(' ');

    // Extract date components
    List<String> dateComponents = components[0].split('/');
    int year = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int day = int.parse(dateComponents[2]);

    // Extract time components
    List<String> timeComponents = components[1].split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    DateTime newDate = DateTime(year, month, day, hour, minute);
    String formattedDate = DateFormat('MMM dd, yyyy').format(newDate);
    return formattedDate;
  }

  static String wrapName(String fullName) {
    List<String> parts = fullName.split(' ');
    if (parts.length < 2) {
      return fullName;
    }
    return '${parts.first[0]} ${parts.last}';
  }

  static String getShortPlayerName(String fullName) {
    if (fullName.trim().isEmpty) return "";

    final parts = fullName.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) return parts[0]; // Single name, return as-is

    // All initials except the last name
    final initials =
        parts.sublist(0, parts.length - 1).map((e) => "${e[0].toUpperCase()}.");
    final lastName = parts.last;

    return "${initials.join(' ')} $lastName";
  }

  Widget showCountdownTimer(
    String time,
    TimerExpiredCallback onTimerExpired,
    BuildContext ctx,
  ) {
    DateTime endDate = DateTime.parse(time);
    bool hasNavigated = false;

    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      alignment: Duration.zero,
      builder: (context) {
        Duration duration = endDate.difference(DateTime.now());

        if (duration.isNegative && !hasNavigated) {
          hasNavigated = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              onTimerExpired();
            }
          });

          return Text(
            "Time's up!",
            style: GoogleFonts.exo2(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        if (hasNavigated) {
          return const SizedBox.shrink();
        }

        String formattedDuration = _formatDuration(duration);
        return Text(
          '$formattedDuration Left',
          style: GoogleFonts.exo2(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget showCountdownTimerTextColorRecentMatches(String time, Color color) {
    DateTime endDate = DateTime.parse(time);
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        Duration duration = endDate.difference(DateTime.now());
        if (duration.isNegative) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Time Over",
              style: GoogleFonts.tomorrow(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          );
        } else if (duration.inHours >= 48) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.tomorrow(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: duration.inDays.toString(),
                    style: const TextStyle(color: AppColors.white),
                  ),
                  const TextSpan(
                    text: ' Days',
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
          );
        } else if (duration.inHours < 48 && duration.inHours >= 4) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.tomorrow(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: duration.inHours.toString(),
                    style: const TextStyle(color: AppColors.white),
                  ),
                  const TextSpan(
                    text: ' Hours',
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
          );
        } else if (duration.inHours < 4 && duration.inHours >= 1) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.tomorrow(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: duration.inHours.toString(),
                    style: const TextStyle(color: AppColors.white),
                  ),
                  const TextSpan(
                    text: ' h : ',
                    style: TextStyle(color: AppColors.white),
                  ),
                  TextSpan(
                    text: (duration.inMinutes % 60).toString().padLeft(2, '0'),
                    style: const TextStyle(color: AppColors.white),
                  ),
                  const TextSpan(
                    text: ' m',
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.tomorrow(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: duration.inMinutes.toString().padLeft(2, '0'),
                    style: const TextStyle(color: AppColors.white),
                  ),
                  const TextSpan(
                    text: ' m : ',
                    style: TextStyle(color: AppColors.white),
                  ),
                  TextSpan(
                    text: (duration.inSeconds % 60).toString().padLeft(2, '0'),
                    style: const TextStyle(color: AppColors.white),
                  ),
                  const TextSpan(
                    text: ' s',
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget showCountdownTimerTextColor(String time, Color color) {
    DateTime endDate = DateTime.parse(time);
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        Duration duration = endDate.difference(DateTime.now());
        if (duration.isNegative) {
          return Text(
            "Time Over",
            style: GoogleFonts.tomorrow(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          );
        } else if (duration.inHours >= 48) {
          return RichText(
            text: TextSpan(
              style: GoogleFonts.tomorrow(
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: duration.inDays.toString(),
                  style: const TextStyle(color: AppColors.black),
                ),
                const TextSpan(
                  text: ' Days',
                  style: TextStyle(color: AppColors.black),
                ),
              ],
            ),
          );
        } else if (duration.inHours < 48 && duration.inHours >= 4) {
          return RichText(
            text: TextSpan(
              style: GoogleFonts.tomorrow(
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: duration.inHours.toString(),
                  style: const TextStyle(color: AppColors.black),
                ),
                const TextSpan(
                  text: ' Hours',
                  style: TextStyle(color: AppColors.black),
                ),
              ],
            ),
          );
        } else if (duration.inHours < 4 && duration.inHours >= 1) {
          return RichText(
            text: TextSpan(
              style: GoogleFonts.tomorrow(
                fontSize: 11.0,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: duration.inHours.toString(),
                  style: const TextStyle(color: AppColors.black),
                ),
                const TextSpan(
                  text: ' h : ',
                  style: TextStyle(color: AppColors.black),
                ),
                TextSpan(
                  text: (duration.inMinutes % 60).toString().padLeft(2, '0'),
                  style: const TextStyle(color: AppColors.black),
                ),
                const TextSpan(
                  text: ' m',
                  style: TextStyle(color: AppColors.black),
                ),
              ],
            ),
          );
        } else {
          return RichText(
            text: TextSpan(
              style: GoogleFonts.tomorrow(
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: duration.inMinutes.toString().padLeft(2, '0'),
                  style: const TextStyle(color: AppColors.black),
                ),
                const TextSpan(
                  text: ' m : ',
                  style: TextStyle(color: AppColors.black),
                ),
                TextSpan(
                  text: (duration.inSeconds % 60).toString().padLeft(2, '0'),
                  style: const TextStyle(color: AppColors.black),
                ),
                const TextSpan(
                  text: ' s',
                  style: TextStyle(color: AppColors.black),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'Time Over';
    } else if (duration.inHours >= 48) {
      return '${duration.inDays} Days';
    } else if (duration.inHours < 48 && duration.inHours >= 4) {
      return '${duration.inHours} Hours';
    } else if (duration.inHours < 4 && duration.inHours >= 1) {
      return '${duration.inHours}h:${(duration.inMinutes % 60)}m';
    } else {
      return '${duration.inMinutes}m:${(duration.inSeconds % 60)}s';
    }
  }

  static String formatAmount(String amount) {
    try {
      double value = double.parse(amount);
      return value.toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  static String htmlToPlainText(String htmlText) {
    htmlText = htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    htmlText = htmlText.replaceAll(RegExp(r'</p>'), '\n\n');

    htmlText = htmlText.replaceAll(RegExp(r'(✨\s*)<strong>'), '✨\n<strong>');

    htmlText = htmlText.replaceAll(RegExp(r'<[^>]*>'), '');

    return htmlText.trim();
  }

  static String maskDigits(String input, int visibleDigits) {
    if (input.length <= visibleDigits) {
      return input;
    }
    return 'X' * (input.length - visibleDigits) +
        input.substring(input.length - visibleDigits);
  }

  static Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static Color determineTextColor(String backgroundColorCode) {
    Color backgroundColor = colorFromHex(backgroundColorCode);
    double luminance = backgroundColor.computeLuminance();

    return luminance > 0.5 ? AppColors.blackColor : AppColors.white;
  }

  static String changeRole(String? role) {
    if (role == "keeper") return "WK";
    if (role == "batsman") return "BAT";
    if (role == "allrounder") return "AR";
    if (role == "bowler") return "BOWL";
    return role!;
  }

  static String stringifyNumber(num number) {
    String formattedNumber = NumberFormat('#,##,##,###.##').format(number);
    return formattedNumber;
  }

  static String changeNumberToValue(num number) {
    var formater = NumberFormat('#,##,##,###.##');
    if (number >= 10000000) {
      return '${formater.format((number) / 10000000)} Cr';
    } else if (number >= 100000) {
      return '${formater.format((number) / 100000)} Lakhs';
      // } else if (number >= 1000) {
      //   return '${formater.format((number) / 1000)} K';
    } else {
      return formater.format(number);
    }
  }

  static String formatDateToDays(String dateString) {
    DateFormat format = DateFormat("dd MMM yyyy HH:mm");

    DateTime givenDate = format.parse(dateString);

    DateTime today = DateTime.now();

    int daysDifference = givenDate.difference(today).inDays;

    return "$daysDifference days";
  }

  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  // static Future<String> getDeviceId(BuildContext context) async {
  //   if (Theme.of(context).platform == TargetPlatform.android) {
  //     AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
  //     return androidInfo.id;
  //   } else if (Theme.of(context).platform == TargetPlatform.iOS) {
  //     IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
  //     return iosInfo.identifierForVendor ?? 'unknown';
  //   }
  //   return 'unknown';
  // }

  static Future<String> getDownloadDirectoryPath() async {
    Directory? downloadDirectory = await getExternalStorageDirectory();
    if (downloadDirectory != null) {
      String downloadPath = '${downloadDirectory.path}/Download';
      return downloadPath;
    } else {
      throw Exception("Failed to get download directory path.");
    }
  }

  static Future<void> installApk(BuildContext context, String apkPath) async {
    try {
      if (Platform.isAndroid) {
        // await ApkInstaller.installApk(filePath: apkPath);
        appToast("APK installation not implemented", context);
      }
    } catch (e) {
      debugPrint('Error: $e');
      appToast("Failed to Install the App!", context);
    }
  }

  static Future<String?> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static bool _isNavigating = false;

  static Future<void> safeNavigatePush(
    BuildContext context,
    Widget screen,
  ) async {
    if (_isNavigating) return;
    _isNavigating = true;

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    _isNavigating = false;
  }

  static Future<void> safeNavigateReplacement(
    BuildContext context,
    Widget screen,
  ) async {
    if (_isNavigating) return;
    _isNavigating = true;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    _isNavigating = false;
  }

  static Future<void> safeNavigateRemoveUntil(
    BuildContext context,
    Widget screen,
  ) async {
    if (_isNavigating) return;
    _isNavigating = true;

    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (Route<dynamic> route) => false,
    );

    _isNavigating = false;
  }
}
// for safe print in debugmode
void printX(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}
