// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_appbar.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/home_datasource.dart';
import 'package:unified_dream247/features/fantasy/landing/domain/use_cases/home_usecases.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/screens/home_page.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/widgets/image_popup_dialog.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/screens/app_drawer.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/my_matches_page.dart';
import 'package:unified_dream247/features/fantasy/winners/presentation/screens/winners_page.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';

class LandingPage extends StatefulWidget {
  final int? index;
  const LandingPage({super.key, this.index});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  String popUpBannerImage = '';
  bool _isFirstLaunch = false;
  bool _isInitializing = true;
  String? _initError;
  HomeUsecases homeUsecases = HomeUsecases(
    HomeDatasource(ApiImplWithAccessToken()),
  );
  late List<Widget> screens;
  // Save Fantasy Auth Token after successful login (dynamic value)
  Future<void> saveFantasyAuthToken(String fantasyToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fantasy_auth_token', fantasyToken);
    await prefs.setString('token', fantasyToken); // Also save as 'token' for API client compatibility
  }

  @override
  void initState() {
    super.initState();
    _initializeFantasyModule();
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
    ];
  }

  /// Initialize Fantasy module - skip token/auth checks, just load app data and wallet
  Future<void> _initializeFantasyModule() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
    });

    try {
      // Only load app data and wallet, skip token/userId checks
      await homeUsecases.getAppDataWithHeader(context);
      if (mounted) {
        final accountsUsecases = AccountsUsecases(
          AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
        );
        await accountsUsecases.myWalletDetails(context);
      }
      checkIfFirstLaunch();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [LANDING_PAGE] Initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initError = e.toString();
        });
      }
    }
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
        debugPrint('Pop-up banner image is null, empty, or already shown.');
      }
    });
  }

  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing
    if (_isInitializing) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.mainColor, AppColors.secondMainColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading Game Zone...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error if initialization failed
    if (_initError != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.mainColor, AppColors.secondMainColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 64),
                  const SizedBox(height: 20),
                  Text(
                    'Unable to load Game Zone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initializeFantasyModule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.mainColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Go Back',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
        drawer: const AppDrawer(),
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
          height: 64.h,
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
            size: 22.sp,
            color: isSelected ? AppColors.secondMainColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
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
