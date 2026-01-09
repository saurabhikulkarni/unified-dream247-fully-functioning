/// Razorpay Backend API Configuration
/// 
/// This file contains the backend API endpoints for Razorpay payment processing.
/// The Razorpay Key Secret should be stored on your backend server, NOT in this frontend code.
/// 
/// Backend endpoints expected:
/// - POST /api/payments/create-order - Create Razorpay order
/// - POST /api/payments/verify-signature - Verify payment signature
/// 
/// See BACKEND_SERVER_SETUP.md for backend implementation details.
library;

class RazorpayBackendConfig {
  // TODO: Update this URL to your deployed backend server
  // For local development: 'http://localhost:3000/api'
  // For production: 'https://your-backend-domain.com/api'
  static const String baseUrl = 'https://brighthex-dream-24-7-backend-psi.vercel.app/api';
  
  // API endpoints
  static const String createOrderEndpoint = '$baseUrl/payments/create-order';
  static const String verifySignatureEndpoint = '$baseUrl/payments/verify-signature';
  
  // Request timeout duration (in seconds)
  static const int requestTimeoutSeconds = 30;
}
