# Production Readiness Checklist

## ✅ Completed Tasks

- [x] All code migrated from both source apps (747 files)
- [x] All imports fixed (564 files)
- [x] All assets copied (321 files)
- [x] Shopping routes integrated
- [x] Fantasy routes integrated
- [x] Environment configuration files created
- [x] Firebase setup (basic configuration)
- [x] Test credentials for Razorpay
- [x] Test credentials for Shiprocket

## ⚠️ Before Production Deploy

### 1. API Configuration
- [ ] Replace staging API URLs with production URLs in `.env.prod`
- [ ] Test all API endpoints are responding
- [ ] Configure API rate limiting
- [ ] Set up API monitoring

### 2. Payment Integration
- [ ] Replace Razorpay test key with production key
- [ ] Test payment flows end-to-end
- [ ] Configure payment webhooks
- [ ] Set up payment failure alerts

### 3. Shipping Integration
- [ ] Replace Shiprocket test credentials with production
- [ ] Test order creation and tracking
- [ ] Configure shipping webhooks
- [ ] Set up shipping failure alerts

### 4. Firebase
- [ ] Run `flutterfire configure` with production project
- [ ] Enable Phone Authentication
- [ ] Enable Cloud Messaging (FCM)
- [ ] Enable Crashlytics
- [ ] Enable Analytics
- [ ] Test push notifications

### 5. Hygraph CMS
- [ ] Replace with production Hygraph endpoint
- [ ] Replace with production auth token
- [ ] Populate production content
- [ ] Test GraphQL queries
- [ ] Set up CMS webhooks

### 6. Security
- [ ] Remove all debug logs
- [ ] Enable code obfuscation
- [ ] Configure ProGuard rules (Android)
- [ ] Enable SSL pinning
- [ ] Audit third-party packages

### 7. Testing
- [ ] Unit tests for critical services
- [ ] Integration tests for user flows
- [ ] UI tests for main screens
- [ ] Performance testing
- [ ] Load testing for APIs

### 8. App Store Preparation
- [ ] Update app version and build number
- [ ] Prepare app screenshots
- [ ] Write app description
- [ ] Prepare privacy policy
- [ ] Prepare terms of service
- [ ] Create app preview video

### 9. Monitoring & Analytics
- [ ] Set up Crashlytics
- [ ] Set up Firebase Analytics
- [ ] Set up custom event tracking
- [ ] Set up error reporting
- [ ] Set up performance monitoring

### 10. Legal & Compliance
- [ ] Review GDPR compliance
- [ ] Review gaming regulations
- [ ] Review payment regulations
- [ ] Update privacy policy
- [ ] Update terms of service

## Testing Instructions

### Test Shopping Flow
1. Launch app → Login
2. Browse products
3. Add to cart
4. Proceed to checkout
5. Enter address
6. Complete payment (test mode)
7. Verify order creation

### Test Fantasy Flow
1. Launch app → Login
2. View upcoming matches
3. Select match → View contests
4. Create team → Select 11 players
5. Choose captain and vice-captain
6. Join contest
7. Verify team created

### Test Wallet
1. Navigate to wallet
2. View balance
3. Add money (test mode)
4. Verify transaction
5. Withdraw money (test mode)
6. View transaction history
