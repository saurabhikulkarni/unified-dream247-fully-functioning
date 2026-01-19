// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
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
import 'package:unified_dream247/features/fantasy/menu_items/data/user_datasource.dart';
import 'package:unified_dream247/features/fantasy/menu_items/domain/use_cases/user_usecases.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';

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
  bool _isInitializing = true;
  String? _initError;
  HomeUsecases homeUsecases = HomeUsecases(
    HomeDatasource(ApiImplWithAccessToken()),
  );
  late List<Widget> screens;
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
      const MoreOptionsPage(),
    ];
  }

  /// Initialize Fantasy module - fetch token and user data
  Future<void> _initializeFantasyModule() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
    });

    try {
      await _verifyUserIdAndInit();
      
      // ✅ CRITICAL: Load app data (payment gateway config, limits, etc.)
      debugPrint('📥 [LANDING_PAGE] Loading app data with payment gateway config...');
      await homeUsecases.getAppDataWithHeader(context);
      debugPrint('✅ [LANDING_PAGE] App data loaded successfully');
      
      // ✅ Load wallet details to populate WalletDetailsProvider
      if (mounted) {
        debugPrint('📥 [LANDING_PAGE] Loading wallet details...');
        final accountsUsecases = AccountsUsecases(
          AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
        );
        await accountsUsecases.myWalletDetails(context);
        debugPrint('✅ [LANDING_PAGE] Wallet details loaded');
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

  /// Verify that userId is available in SharedPreferences
  /// This ensures the user is properly logged in with Hygraph credentials
  Future<void> _verifyUserIdAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    
    // First check if user is logged in at all
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) {
      debugPrint('⚠️ [LANDING_PAGE] User not logged in');
      if (mounted) {
        context.go('/shop/login');
      }
      return;
    }
    
    final userId = await UserIdHelper.getUnifiedUserId();
    
    if (userId.isEmpty) {
      debugPrint('⚠️ [LANDING_PAGE] No userId found! User is not logged in.');
      if (mounted) {
        debugPrint('🔄 [LANDING_PAGE] Redirecting to Shop login for authentication');
        context.go('/shop/login');
      }
      return;
    }
    
    debugPrint('✅ [LANDING_PAGE] UserId verified: ${userId.substring(0, userId.length > 20 ? 20 : userId.length)}...');
    
    // Get user phone and name for token fetch
    final phone = prefs.getString('user_phone') ?? '';
    final name = prefs.getString('user_name') ?? '';
    
    debugPrint('📱 [LANDING_PAGE] Phone: $phone, Name: $name');
    
    // Check if fantasy token exists and is valid
    String? token = prefs.getString('token');
    bool tokenRefreshed = false;
    
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ [LANDING_PAGE] No fantasy token found, fetching...');
      token = await _fetchAndSaveFantasyToken(prefs, phone, name, userId);
      tokenRefreshed = token != null;
    } else {
      debugPrint('✅ [LANDING_PAGE] Fantasy token found: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    }
    
    // If we still don't have a token, show error
    if (token == null || token.isEmpty) {
      debugPrint('❌ [LANDING_PAGE] Could not obtain fantasy token');
      throw Exception('Could not authenticate with Fantasy server. Please try logging in again.');
    }
    
    // Fetch user details from Fantasy backend to populate UserDataProvider
    if (mounted) {
      debugPrint('📥 [LANDING_PAGE] Fetching user details from Fantasy backend...');
      final userUsecases = UserUsecases(UserDatasource(ApiImplWithAccessToken()));
      final success = await userUsecases.getUserDetails(context);
      
      if (success == true) {
        debugPrint('✅ [LANDING_PAGE] User details fetched successfully');
      } else {
        debugPrint('⚠️ [LANDING_PAGE] getUserDetails returned false, retrying with fresh token...');
        
        // Token might be expired - try refreshing
        if (!tokenRefreshed) {
          final newToken = await _fetchAndSaveFantasyToken(prefs, phone, name, userId);
          if (newToken != null) {
            // Retry getting user details
            final retrySuccess = await userUsecases.getUserDetails(context);
            if (retrySuccess != true) {
              debugPrint('❌ [LANDING_PAGE] Failed to fetch user details even after token refresh');
            }
          }
        }
      }
    }
    
    // Show all stored keys for debugging
    await UserIdHelper.debugPrintStoredKeys();
  }

  /// Helper to fetch and save fantasy token
  Future<String?> _fetchAndSaveFantasyToken(
    SharedPreferences prefs,
    String phone,
    String name,
    String userId,
  ) async {
    if (phone.isEmpty) {
      debugPrint('❌ [LANDING_PAGE] Cannot fetch token - no phone number');
      return null;
    }
    
    try {
      final authService = AuthService();
      final fantasyToken = await authService.fetchFantasyToken(
        phone: phone,
        name: name,
        userId: userId,
        isNewUser: false,
      );
      
      if (fantasyToken != null && fantasyToken.isNotEmpty) {
        await prefs.setString('token', fantasyToken);
        await prefs.setString('auth_token', fantasyToken);
        debugPrint('✅ [LANDING_PAGE] Fantasy token fetched and saved');
        debugPrint('✅ [LANDING_PAGE] Token: ${fantasyToken.substring(0, fantasyToken.length > 30 ? 30 : fantasyToken.length)}...');
        return fantasyToken;
      } else {
        debugPrint('❌ [LANDING_PAGE] Fantasy backend returned null/empty token');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [LANDING_PAGE] Error fetching fantasy token: $e');
      return null;
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
    // Show loading while initializing
    if (_isInitializing) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
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
                    fontSize: 16,
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
          decoration: BoxDecoration(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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
