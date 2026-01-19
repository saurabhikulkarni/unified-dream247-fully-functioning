// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_appbar.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/core/utils/user_id_helper.dart';
import 'package:unified_dream247/features/fantasy/landing/data/home_datasource.dart';
import 'package:unified_dream247/features/fantasy/landing/domain/use_cases/home_usecases.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/screens/home_page.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/widgets/image_popup_dialog.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/screens/app_drawer.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/more_options_page.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/my_matches_page.dart';
import 'package:unified_dream247/features/fantasy/winners/presentation/screens/winners_page.dart';

class LandingPage extends StatefulWidget {
  final int? index;
  const LandingPage({super.key, this.index});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  String popUpBannerImage = "";
  bool _isFirstLaunch = false;
  HomeUsecases homeUsecases = HomeUsecases(
    HomeDatasource(ApiImplWithAccessToken()),
  );
  late List<Widget> screens;
  @override
  void initState() {
    super.initState();
    _verifyUserIdAndInit();
    checkIfFirstLaunch();
    screens = [
      HomePage(updateIndex: updateIndex),
      MyMatchesPage(
        updateIndex: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const WinnersPage(),
      const MoreOptionsPage(),
    ];
  }

  /// Verify that userId is available in SharedPreferences
  /// This ensures the user is properly logged in with Hygraph credentials
  Future<void> _verifyUserIdAndInit() async {
    try {
      final userId = await UserIdHelper.getUnifiedUserId();
      
      if (userId.isEmpty) {
        debugPrint('⚠️ [LANDING_PAGE] No userId found! User is not logged in.');
        // Redirect to Shop login screen - user must authenticate first
        if (mounted) {
          debugPrint('🔄 [LANDING_PAGE] Redirecting to Shop login for authentication');
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      } else {
        debugPrint('✅ [LANDING_PAGE] UserId verified: ${userId.substring(0, userId.length > 20 ? 20 : userId.length)}...');
        debugPrint('✅ [LANDING_PAGE] User is properly authenticated for Fantasy features');
      }
      
      // Show all stored keys for debugging
      await UserIdHelper.debugPrintStoredKeys();
    } catch (e) {
      debugPrint('❌ [LANDING_PAGE] Error verifying userId: $e');
      // On error, redirect to login for safety
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) Navigator.pop(context);
  }

  Future<void> checkIfFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownBanner = prefs.getBool('hasShownPopup') ?? false;
    if (!hasShownBanner) {
      _isFirstLaunch = true;
      fetchAndShowPopUpBanner();
    }
  }

  void fetchAndShowPopUpBanner() async {
    homeUsecases.fetchPopUpBanner(context).then((value) async {
      if (value != null && value.isNotEmpty && _isFirstLaunch) {
        setState(() {
          popUpBannerImage = value;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ImagePopupDialog(image: value);
          },
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('hasShownPopup', true);
      } else {
        debugPrint("Pop-up banner image is null, empty, or already shown.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to unified home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        key: AppUtils.scaffoldKey,
        appBar: MainAppbar(
          title: _getAppBarTitle(),
        ),
        drawer: AppDrawer(),
        body: screens[_selectedIndex],
        bottomNavigationBar: _buildPremiumBottomBar(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'My Matches';
      case 2:
        return 'Winners';
      case 3:
        return 'More';
      default:
        return 'Dream247';
    }
  }

  Widget _buildPremiumBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
            // top: BorderSide(color: Color(0xFF8A5BFF), width: 2),
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomItem(
                icon: Icons.home_outlined,
                label: 'Home',
                index: 0,
              ),
              _bottomItem(
                icon: Icons.flag_outlined,
                label: 'My Matches',
                index: 1,
              ),
              _bottomItem(
                icon: Icons.emoji_events_outlined,
                label: 'Winners',
                index: 2,
              ),
              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.secondMainColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.secondMainColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildPremiumBottomBar() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: AppColors.lightCard,
  //       borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.black.withAlpha(98),
  //           blurRadius: 10,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //         child: GNav(
  //           gap: 8,
  //           color: AppColors.greyColor,
  //           activeColor: AppColors.white,
  //           tabBackgroundGradient: AppColors.appBarGradient,
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //           selectedIndex: _selectedIndex,
  //           onTabChange: (index) => setState(() => _selectedIndex = index),
  //           tabs: const [
  //             GButton(icon: Icons.home_outlined, text: "Home"),
  //             GButton(icon: Icons.stadium, text: "My Matches"),
  //             GButton(icon: Icons.military_tech, text: "Winners"),
  //             GButton(icon: Icons.more_horiz_outlined, text: "More"),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
