import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

/// Web implementation of Razorpay using JavaScript Checkout
class RazorpayPlatform {
  Function(Map<String, dynamic>)? _onSuccess;
  Function(String)? _onError;
  Function()? _onDismiss;

  void init({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
    required Function() onDismiss,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onDismiss = onDismiss;
  }

  void open(Map<String, dynamic> options) {
    try {
      if (kDebugMode) {
        print('[RAZORPAY_WEB] Opening payment with options...');
      }
      // Check if Razorpay is loaded
      if (!js.context.hasProperty('Razorpay')) {
        if (kDebugMode) {
          print('[RAZORPAY_WEB] ERROR: Razorpay library not loaded');
        }
        _onError?.call('Razorpay library not loaded. Please refresh the page.');
        return;
      }

      // Create a copy of options without handler/modal (we'll add them separately)
      final optionsMap = Map<String, dynamic>.from(options);
      
      // Remove handler and modal if they exist
      optionsMap.remove('handler');
      optionsMap.remove('modal');
      
      // Convert to JS object
      final jsOptions = js.JsObject.jsify(optionsMap);

      // Create handler callback - Razorpay expects: handler: function(response) {...}
      jsOptions['handler'] = js.allowInterop((response) {
        if (kDebugMode) {
          print('[RAZORPAY_WEB] ✅ Payment SUCCESS - handler called');
          print('[RAZORPAY_WEB] Response type: ${response.runtimeType}');
        }
        try{
          // Try to extract payment details - response can be JsObject or Map
          String paymentId = '';
          String orderId = '';
          String signature = '';
          
          if (response is js.JsObject) {
            paymentId = response['razorpay_payment_id']?.toString() ?? '';
            orderId = response['razorpay_order_id']?.toString() ?? '';
            signature = response['razorpay_signature']?.toString() ?? '';
          } else {
            // Try as dynamic object
            try {
              paymentId = js_util.getProperty(response, 'razorpay_payment_id')?.toString() ?? '';
              orderId = js_util.getProperty(response, 'razorpay_order_id')?.toString() ?? '';
              signature = js_util.getProperty(response, 'razorpay_signature')?.toString() ?? '';
            } catch (e) {
              if (kDebugMode) {
                print('[RAZORPAY_WEB] js_util failed, trying direct access: $e');
                // Last resort - try to convert to string and parse
                final responseStr = response.toString();
                print('[RAZORPAY_WEB] Response as string: $responseStr');
              }
            }
          }
          
          if (kDebugMode) {
            print('[RAZORPAY_WEB] Payment ID: $paymentId');
            print('[RAZORPAY_WEB] Order ID: $orderId');
            print('[RAZORPAY_WEB] Signature: ${signature.isNotEmpty ? "present" : "missing"}');
          }
          
          if (paymentId.isEmpty || orderId.isEmpty || signature.isEmpty) {
            if (kDebugMode) {
              print('[RAZORPAY_WEB] WARNING: Missing payment details!');
            }
            _onError?.call('Payment completed but details not received. Please contact support.');
            return;
          }
          
          _onSuccess?.call({
            'razorpay_payment_id': paymentId,
            'razorpay_order_id': orderId,
            'razorpay_signature': signature,
          });
        } catch (e) {
          if (kDebugMode) {
            print('[RAZORPAY_WEB] ERROR parsing success response: $e');
          }
          _onError?.call('Error processing payment response: $e');
        }
      });
      
      // Create modal options for dismiss/error handling
      final modalOptions = js.JsObject.jsify({});
      modalOptions['ondismiss'] = js.allowInterop(() {
        if (kDebugMode) {
          print('[RAZORPAY_WEB] ⚠️ Payment modal DISMISSED');
        }
        _onDismiss?.call();
      });
      jsOptions['modal'] = modalOptions;

      if (kDebugMode) {
        print('[RAZORPAY_WEB] Creating Razorpay instance...');
      }
      // Create Razorpay instance
      final razorpayConstructor = js.context['Razorpay'] as js.JsFunction;
      final razorpay = js.JsObject(razorpayConstructor, [jsOptions]);
      
      if (kDebugMode) {
        print('[RAZORPAY_WEB] Opening Razorpay checkout...');
      }
      razorpay.callMethod('open');
    } catch (e) {
      if (kDebugMode) {
        print('[RAZORPAY_WEB] ERROR: $e');
      }
      _onError?.call('Failed to open Razorpay checkout. Error: $e');
    }
  }

  void dispose() {
    _onSuccess = null;
    _onError = null;
    _onDismiss = null;
  }
}
