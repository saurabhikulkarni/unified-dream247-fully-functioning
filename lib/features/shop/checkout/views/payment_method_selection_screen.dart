import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/payment_model.dart';
import 'package:unified_dream247/features/shop/services/razorpay_service.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';
import '../components/payment_method_card.dart';

class PaymentMethodSelectionScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId;

  const PaymentMethodSelectionScreen({
    super.key,
    required this.totalAmount,
    required this.orderId,
  });

  @override
  State<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState
    extends State<PaymentMethodSelectionScreen> {
  late RazorpayService _razorpayService;
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  final UnifiedWalletService _walletService = UnifiedWalletService();
  double _availableShopTokens = 0.0;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _loadShopTokenBalance();
  }

  Future<void> _loadShopTokenBalance() async {
    try {
      await _walletService.initialize();
      final balance = await _walletService.getShopTokens();
      if (mounted) {
        setState(() {
          _availableShopTokens = balance;
        });
      }
    } catch (e) {
      debugPrint('Error loading shop token balance: $e');
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if user has enough tokens for token payment
    if (_selectedPaymentMethod == PaymentMethod.shopTokens) {
      if (_availableShopTokens < widget.totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient tokens. You need ${widget.totalAmount.toInt()} tokens but have ${_availableShopTokens.toInt()} available.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Process token payment directly
      _processTokenPayment();
    } else {
      _initiatePayment();
    }
  }

  Future<void> _processTokenPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Deduct tokens from wallet
      final success = await _walletService.deductShopTokens(
        widget.totalAmount,
        itemName: 'Order ${widget.orderId}',
      );

      if (!mounted) return;

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaymentSuccessDialog(
            orderId: widget.orderId,
            amount: widget.totalAmount,
            paymentId: 'token_${DateTime.now().millisecondsSinceEpoch}',
            onContinue: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context, {
                'status': 'success',
                'paymentId': 'token_${DateTime.now().millisecondsSinceEpoch}',
                'orderId': widget.orderId,
                'paymentMethod': 'shopTokens',
              });
            },
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process token payment'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing token payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _initiatePayment() async {
    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentLoadingDialog(
        message: 'Initiating payment...',
      ),
    );

    // Fetch user data from AuthService
    final authService = AuthService();
    final userPhone = await authService.getUserPhone() ?? '+91 0000000000';
    final userName = await authService.getUserName() ?? 'Customer';
    // Using placeholder email until user profile is extended with email field
    const userEmail = 'customer@dream247.com';

    // Simulate delay for order creation on backend
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Start Razorpay payment
        _razorpayService.startPayment(
          orderId: widget.orderId,
          amount: widget.totalAmount,
          userEmail: userEmail,
          userPhone: userPhone,
          userName: userName,
          preferredMethod: _selectedPaymentMethod,
          onSuccess: (response) {
            _handlePaymentSuccess(response);
          },
          onError: (error) {
            _handlePaymentError(error);
          },
          onDismiss: () {
            _handlePaymentDismiss();
          },
        );

        setState(() => _isProcessing = false);
      }
    });
  }

  void _handlePaymentSuccess(RazorpayPaymentResponse response) {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentSuccessDialog(
        orderId: widget.orderId,
        amount: widget.totalAmount,
        paymentId: response.paymentId,
        onContinue: () {
          Navigator.pop(context); // Close success dialog
          Navigator.pop(context, {
            'status': 'success',
            'paymentId': response.paymentId,
            'orderId': response.orderId,
            'signature': response.signature,
          });
        },
      ),
    );
  }

  void _handlePaymentError(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentErrorDialog(
        errorMessage: error,
        onRetry: () {
          Navigator.pop(context); // Close error dialog
          _initiatePayment(); // Retry payment
        },
        onCancel: () {
          Navigator.pop(context); // Close error dialog
          setState(() => _isProcessing = false);
        },
      ),
    );
  }

  void _handlePaymentDismiss() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment cancelled'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final supportedMethods = _razorpayService.getSupportedPaymentMethods();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Order Summary
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            color: const Color(0xFF6441A5).withOpacity(0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2A0845),
                      ),
                    ),
                    Text(
                      RazorpayService().formatAmount(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6441A5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding / 2),
                const Divider(),
                const SizedBox(height: defaultPadding / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Amount to Pay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A0845),
                      ),
                    ),
                    Text(
                      RazorpayService().formatAmount(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6441A5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Payment Methods Grid
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(defaultPadding),
              children: [
                const Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A0845),
                  ),
                ),
                const SizedBox(height: defaultPadding),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: defaultPadding,
                    mainAxisSpacing: defaultPadding,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: supportedMethods.length,
                  itemBuilder: (context, index) {
                    final method = supportedMethods[index];
                    return PaymentMethodCard(
                      method: method,
                      isSelected: _selectedPaymentMethod == method,
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: defaultPadding * 2),
                // Security Info
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: const Color(0xFF219A00).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                    border: Border.all(
                      color: const Color(0xFF219A00).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Color(0xFF219A00),
                        size: 20,
                      ),
                      const SizedBox(width: defaultPadding / 2),
                      Expanded(
                        child: Text(
                          'Your payment is secured with 256-bit SSL encryption',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Razorpay Secure Gateway',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: _isProcessing ? null : _proceedToPayment,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
