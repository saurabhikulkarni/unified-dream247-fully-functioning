import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/services/razorpay_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';

import 'components/wallet_balance_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double walletBalance = 0.0;
  int shoppingTokens = 0;
  double? requiredAmount;
  bool returnToCart = false;
  final TextEditingController _amountController = TextEditingController();
  double _selectedTopUpAmount = 0.0;
  final UserService _userService = userService;
  bool _isLoading = false;
  bool _hasLoadedInitialBalance = false; // Track if we've loaded balance
  bool _skipNextLoad = false; // Skip load after payment success

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get arguments passed from navigation
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.isNotEmpty) {
      setState(() {
        walletBalance = (args['walletBalance'] ?? 0.0) as double;
        shoppingTokens = (args['shoppingTokens'] ?? 0) as int;
        requiredAmount = args['requiredAmount'] as double?;
        returnToCart = args['returnToCart'] ?? false;
      });
      
      // If required amount is specified, pre-fill it
      if (requiredAmount != null && requiredAmount! > 0) {
        _selectedTopUpAmount = requiredAmount!;
        _amountController.text = requiredAmount!.toStringAsFixed(0);
      }
    }
    
    // Load balance from GraphQL if user is logged in
    // Only load once, or if we haven't just completed a payment
    if (!_hasLoadedInitialBalance && !_skipNextLoad) {
      _loadWalletBalance();
      _hasLoadedInitialBalance = true;
    } else if (_skipNextLoad) {
      print('[WALLET_SCREEN] Skipping balance load after payment');
      _skipNextLoad = false; // Reset flag
    }
  }

  Future<void> _loadWalletBalance() async {
    final userId = UserService.getCurrentUserId();
    print('[WALLET_SCREEN] _loadWalletBalance: userId=$userId');
    if (userId != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final balance = await _userService.getWalletBalance();
        print('[WALLET_SCREEN] Wallet balance loaded from service: $balance');
        if (mounted) {
          setState(() {
            walletBalance = balance;
            shoppingTokens = balance.toInt();
            _isLoading = false;
          });
        }
      } catch (e) {
        print('[WALLET_SCREEN] Error loading wallet balance: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _addMoney(double amount) async {
    final userId = UserService.getCurrentUserId();
    print('[WALLET_SCREEN] _addMoney called: userId=$userId, amount=$amount');
    print('[WALLET_SCREEN] Current balance BEFORE: $walletBalance (tokens: $shoppingTokens)');
    
    // Initialize and sync with unified wallet service
    await walletService.initialize();
    await walletService.addShopTokens(amount);
    
    if (userId != null) {
      // Update balance in GraphQL
      try {
        final newBalance = await _userService.addWalletBalance(userId, amount);
        print('[WALLET_SCREEN] addWalletBalance returned: $newBalance');
        if (newBalance != null) {
          // Always use the returned balance from addWalletBalance
          // It's the most up-to-date value (either from backend or cache)
          setState(() {
            walletBalance = newBalance;
            shoppingTokens = newBalance.toInt();
            _skipNextLoad = true; // Skip next didChangeDependencies load
          });
          print('[WALLET_SCREEN] State updated - walletBalance: $walletBalance, shoppingTokens: $shoppingTokens');
          return;
        }
      } catch (e) {
        print('[WALLET_SCREEN] Error in _addMoney: $e');
        // If there's an exception, still try to update locally
      }
    }
    
    // Fallback: Local update if GraphQL fails or no user ID
    setState(() {
      walletBalance += amount;
      shoppingTokens = walletBalance.toInt();
      _skipNextLoad = true; // Skip next didChangeDependencies load
    });
    print('[WALLET_SCREEN] Local update - walletBalance: $walletBalance, shoppingTokens: $shoppingTokens');
  }

  void _initiatePayment() async {
    if (_selectedTopUpAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is logged in
    final userId = UserService.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add money to wallet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch user data from AuthService
      final authService = AuthService();
      final userPhone = await authService.getUserPhone() ?? '+91 0000000000';
      final userName = await authService.getUserName() ?? 'Customer';
      // Using placeholder email until user profile is extended with email field
      const userEmail = 'customer@dream247.com';

      final razorpayService = RazorpayService();
      
      // Create order on backend first
      final receipt = 'wallet_topup_${DateTime.now().millisecondsSinceEpoch}';
      final razorpayOrder = await razorpayService.createOrder(
        amount: _selectedTopUpAmount,
        receipt: receipt,
        notes: {
          'type': 'wallet_topup',
          'userId': userId, // Use validated userId
        },
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      if (razorpayOrder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create payment order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Now start payment with the created order ID
      print('[WALLET] 🚀 Starting Razorpay payment for amount: $_selectedTopUpAmount');
      razorpayService.startPayment(
        orderId: razorpayOrder.razorpayOrderId,
        amount: _selectedTopUpAmount,
        userEmail: userEmail,
        userPhone: userPhone,
        userName: userName,
      onSuccess: (response) async {
        print('[WALLET] ✅ Payment SUCCESS callback triggered!');
        print('[WALLET] Payment ID: ${response.paymentId}');
        print('[WALLET] Order ID: ${razorpayOrder.razorpayOrderId}');
        try {
          // Verify payment signature on backend
          print('[WALLET] Verifying payment signature...');
          final razorpayService = RazorpayService();
          final isVerified = await razorpayService.verifyPaymentSignature(
            paymentId: response.paymentId,
            orderId: razorpayOrder.razorpayOrderId,
            signature: response.signature,
          );

          print('[WALLET] Signature verification result: $isVerified');
          if (!isVerified) {
            print('[WALLET] ❌ Signature verification FAILED');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment verification failed. Please contact support.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          // Payment verified, add money to wallet
          print('[WALLET] ✅ Payment verified! Adding money: $_selectedTopUpAmount');
          await _addMoney(_selectedTopUpAmount);
          
          if (!mounted) return;
          
          print('[WALLET] Balance after add money: $walletBalance tokens: $shoppingTokens');
          
          // Force complete UI refresh to update WalletBalanceCard
          setState(() {
            _selectedTopUpAmount = 0;
            _amountController.clear();
            // Force rebuild by updating state variables
            walletBalance = walletBalance;
            shoppingTokens = shoppingTokens;
          });
          
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Successfully added ₹${walletBalance.toStringAsFixed(0)} to wallet!\nNew balance: $shoppingTokens tokens",
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );

          // If returning to cart, pop with updated balance
          if (returnToCart) {
            Navigator.pop(context, {
              'walletBalance': walletBalance,
              'shoppingTokens': shoppingTokens,
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing payment: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onError: (error) {
        print('[WALLET] ❌ Payment ERROR callback triggered!');
        print('[WALLET] Error: $error');
        // Payment failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Payment failed: $error",
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      },
      onDismiss: () {
        // Payment dismissed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Payment cancelled",
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initiating payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Widget _buildQuickSelectButton(double amount) {
    final isSelected = _selectedTopUpAmount == amount;
    final buttonWidth = MediaQuery.of(context).size.width * 0.27;
    final fontSize = context.fontSize(10, minSize: 8, maxSize: 12);
    final amountFontSize = context.fontSize(14, minSize: 12, maxSize: 16);
    
    return SizedBox(
      width: buttonWidth,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedTopUpAmount = amount;
            _amountController.text = amount.toStringAsFixed(0);
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isSelected ? const Color(0xFF219A00) : Colors.grey[400]!,
            width: 2,
          ),
          backgroundColor: isSelected ? const Color(0xFF219A00).withOpacity(0.1) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          children: [
            Text(
              "Add",
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              "₹${amount.toStringAsFixed(0)}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFF219A00) : Colors.grey[600],
                fontSize: amountFontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({
          'walletBalance': walletBalance,
          'shoppingTokens': shoppingTokens,
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Wallet"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop({
                'walletBalance': walletBalance,
                'shoppingTokens': shoppingTokens,
              });
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WalletBalanceCard(
                                balance: walletBalance,
                                shoppingTokens: shoppingTokens,
                                onTabChargeBalance: () {},
                              ),
                              if (requiredAmount != null && requiredAmount! > 0) ...[
                                const SizedBox(height: defaultPadding),
                                Container(
                                  padding: const EdgeInsets.all(defaultPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                                      const SizedBox(width: defaultPadding / 2),
                                      Expanded(
                                        child: Text(
                                          'You need ${requiredAmount!.toInt()} more tokens to complete your purchase',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: context.fontSize(13, minSize: 11, maxSize: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: defaultPadding * 2),
                              // Add Top-up Section
                              Text(
                                "Add Top-up to get Shopping Tokens",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: defaultPadding),
                              // Input field
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      _selectedTopUpAmount = 0;
                                    } else {
                                      _selectedTopUpAmount = double.tryParse(value) ?? 0;
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Enter amount here",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                              const SizedBox(height: defaultPadding),
                              // Quick select buttons
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildQuickSelectButton(50),
                                    SizedBox(width: context.responsiveSpacing),
                                    _buildQuickSelectButton(100),
                                    SizedBox(width: context.responsiveSpacing),
                                    _buildQuickSelectButton(200),
                                  ],
                                ),
                              ),
                              const SizedBox(height: defaultPadding * 1.5),
                              // Add Top-up button
                              ElevatedButton(
                                onPressed: _selectedTopUpAmount > 0
                                    ? () {
                                        _initiatePayment();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedTopUpAmount > 0
                                      ? const Color(0xFF219A00)
                                      : Colors.grey[400],
                                  disabledBackgroundColor: Colors.grey[400],
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                                  ),
                                ),
                                child: Text(
                                  _selectedTopUpAmount > 0
                                      ? "Add ₹${_selectedTopUpAmount.toStringAsFixed(0)}"
                                      : "Add Top-up",
                                  style: TextStyle(
                                    fontSize: context.fontSize(16, minSize: 14, maxSize: 18),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Transaction history feature - reserved for future integration
                      // with backend payment history when available
                      // SliverPadding(
                      //   padding: const EdgeInsets.only(top: defaultPadding / 2),
                      //   sliver: SliverToBoxAdapter(
                      //     child: Text(
                      //       "Transaction History",
                      //       style: Theme.of(context).textTheme.titleSmall,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
