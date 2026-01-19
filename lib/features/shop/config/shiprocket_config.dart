import 'package:unified_dream247/config/api_config.dart';

class ShiprocketConfig {
  // Shiprocket API Configuration
  // Official Documentation: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet
  // API Docs: https://apidocs.shiprocket.in
  //
  // ⚠️ IMPORTANT: Credentials are now stored on the backend server for security!
  // The proxyUrl below points to your backend API which handles authentication.
  // Credentials below are kept for backward compatibility but are NOT used when proxyUrl is configured.
  
  // OPTION 1: Use direct API token (for direct API calls - not recommended)
  // If you have a token, set it here to skip authentication
  // Token is valid for 240 hours (10 days) according to Shiprocket docs
  // NOTE: Not used when proxyUrl is configured (backend handles authentication)
  static const String? apiToken = null; 
  // Example: static const String? apiToken = 'your_api_token_here';
  
  // OPTION 2: Use API User credentials for authentication (for direct API calls - not recommended)
  // IMPORTANT: These must be API User credentials, NOT your main Shiprocket account!
  // NOTE: Not used when proxyUrl is configured (backend handles authentication)
  // 
  // Steps to create API User:
  // 1. Go to Shiprocket Panel → Settings → API
  // 2. Click "Create an API User"
  // 3. Enter a Valid Email ID (MUST be different from your registered email)
  // 4. Input an appropriate password
  // 5. Use these credentials below (NOT your main account credentials)
  //
  // Reference: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet
  // ⚠️ TEST MODE - Replace with production credentials before launch
  static const String email = 'brigthtestShipTest@gmail.com';
  static const String password = 'Xm1ULRgo*I9rC5NvZUW!K#^^Bo&Tx*C8';  
  // Shiprocket API Base URL (for direct API calls - not used when proxyUrl is configured)
  // Base URL: apiv2.shiprocket.in
  // Full base URL: https://apiv2.shiprocket.in/v1/external
  static const String baseUrl = 'https://apiv2.shiprocket.in/v1/external';
  
  // OPTION 3: Backend Proxy URL (RECOMMENDED - for all platforms)
  // If you have a backend proxy server that forwards requests to Shiprocket,
  // set the proxy URL here. This will be used instead of direct API calls.
  // This approach:
  // - Avoids CORS issues on Flutter Web
  // - Keeps credentials secure on the backend
  // - Works on all platforms (web, mobile, desktop)
  // 
  // Now uses centralized ApiConfig for environment-based URL switching
  static String get proxyUrl => '${ApiConfig.shopApiUrl}/shiprocket';
  
  // Note: When proxyUrl is configured, all Shiprocket API calls go through the backend.
  // Credentials (email/password or API token) should be stored in backend environment variables.
  // See backend/.env file for SHIPROCKET_EMAIL, SHIPROCKET_PASSWORD, or SHIPROCKET_API_TOKEN
}
