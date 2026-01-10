# MSG91 OTP Authentication Flow

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        APP START                             │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    SPLASH SCREEN                             │
│  • Animated "DREAM247" typing effect                         │
│  • Purple gradient background                                │
│  • Checks AuthLocalDataSource.isLoggedIn()                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
         [Is Logged In?]            │
                │                   │
        ┌───────┴───────┐           │
        │               │           │
       YES             NO           │
        │               │           │
        ▼               ▼           │
   ┌─────────┐    ┌─────────┐      │
   │  HOME   │    │  LOGIN  │      │
   │  PAGE   │    │  PAGE   │      │
   └─────────┘    └────┬────┘      │
                       │            │
                       ▼            │
┌─────────────────────────────────────────────────────────────┐
│                      LOGIN PAGE                              │
│  • Phone number input (10 digits)                            │
│  • Validation: Starts with 6-9                               │
│  • "Send OTP" button                                         │
│  • Link to Register page                                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                  [User enters phone]
                          │
                          ▼
                  ┌───────────────┐
                  │ Validate Form │
                  └───────┬───────┘
                          │
                  [Valid?]─────────NO──────> Show error
                          │
                         YES
                          │
                          ▼
                  ┌───────────────┐
                  │  SendOtpEvent │
                  │  (BLoC)       │
                  └───────┬───────┘
                          │
                          ▼
         ┌────────────────────────────────────┐
         │   POST /api/auth/send-otp          │
         │   {                                 │
         │     "mobileNumber": "9876543210"    │
         │   }                                 │
         └────────────────┬───────────────────┘
                          │
                  [Backend sends SMS]
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                 OTP VERIFICATION PAGE                        │
│  • 6-digit PIN code input (pin_code_fields)                  │
│  • Countdown timer: 60s                                      │
│  • Resend OTP button (disabled until timer = 0)             │
└─────────────────────────┬───────────────────────────────────┘
                          │
                  [User enters OTP]
                          │
                          ▼
                  ┌───────────────┐
                  │ OTP Complete? │
                  │ (6 digits)    │
                  └───────┬───────┘
                          │
                         YES
                          │
                          ▼
                  ┌───────────────┐
                  │ VerifyOtpEvent│
                  │  (BLoC)       │
                  └───────┬───────┘
                          │
                          ▼
         ┌────────────────────────────────────┐
         │   POST /api/auth/verify-otp        │
         │   {                                 │
         │     "mobileNumber": "9876543210",   │
         │     "otp": "123456"                 │
         │   }                                 │
         └────────────────┬───────────────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
          [OTP Correct?]            │
                │                   │
        ┌───────┴───────┐           │
        │               │           │
       YES             NO           │
        │               │           │
        ▼               ▼           │
   ┌─────────┐    ┌─────────┐      │
   │ SUCCESS │    │  ERROR  │      │
   └────┬────┘    └────┬────┘      │
        │               │           │
        │               └──> Show snackbar
        │                           │
        ▼                           │
┌─────────────────────────────────────────────────────────────┐
│                    SESSION SAVED                             │
│  1. AuthLocalDataSource:                                     │
│     • Save user to SharedPreferences                         │
│     • Save tokens to SecureStorage (encrypted)               │
│  2. Shop AuthService:                                        │
│     • Save unified session for backward compatibility        │
│  3. Navigate to HOME                                         │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
                    ┌──────────┐
                    │   HOME   │
                    │   PAGE   │
                    └──────────┘
```

## Resend OTP Flow

```
┌─────────────────────────────────────────────────────────────┐
│              OTP VERIFICATION PAGE (Timer = 0)               │
│  • Countdown finished                                        │
│  • "Resend OTP" button enabled                               │
└─────────────────────────┬───────────────────────────────────┘
                          │
                  [User taps "Resend OTP"]
                          │
                          ▼
                  ┌───────────────┐
                  │  SendOtpEvent │
                  │  (BLoC)       │
                  └───────┬───────┘
                          │
                          ▼
         ┌────────────────────────────────────┐
         │   POST /api/auth/send-otp          │
         │   (Same as initial send)            │
         └────────────────┬───────────────────┘
                          │
                  [Backend sends new SMS]
                          │
                          ▼
                  ┌───────────────┐
                  │ Reset Timer   │
                  │ to 60s        │
                  └───────┬───────┘
                          │
                          ▼
                  [User enters new OTP]
```

## Auto-Login Flow (App Restart)

```
┌─────────────────────────────────────────────────────────────┐
│                    APP RESTART                               │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    SPLASH SCREEN                             │
│  • Shows typing animation                                    │
│  • Checks AuthLocalDataSource.isLoggedIn()                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
                  ┌───────────────┐
                  │ Check Storage │
                  │ for tokens    │
                  └───────┬───────┘
                          │
                ┌─────────┴─────────┐
                │                   │
         [Has valid token?]         │
                │                   │
        ┌───────┴───────┐           │
        │               │           │
       YES             NO           │
        │               │           │
        ▼               ▼           │
   ┌─────────┐    ┌─────────┐      │
   │ Navigate│    │ Navigate│      │
   │ to HOME │    │ to LOGIN│      │
   └─────────┘    └─────────┘      │
        │                           │
   [User is logged in]         [Must login]
```

## Logout Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  USER TAPS LOGOUT                            │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              CONFIRMATION DIALOG                             │
│  "Are you sure you want to logout?"                          │
│  [Cancel]  [Logout]                                          │
└─────────────────────────┬───────────────────────────────────┘
                          │
                  [User confirms]
                          │
                          ▼
                  ┌───────────────┐
                  │  LogoutEvent  │
                  │  (BLoC)       │
                  └───────┬───────┘
                          │
                          ▼
         ┌────────────────────────────────────┐
         │   CLEAR ALL DATA                   │
         │   1. AuthLocalDataSource.clear()   │
         │   2. Shop AuthService.logout()     │
         │   3. Clear all providers           │
         └────────────────┬───────────────────┘
                          │
                          ▼
                  ┌───────────────┐
                  │ Navigate to   │
                  │ LOGIN page    │
                  └───────────────┘
```

## State Management (BLoC)

```
┌─────────────────────────────────────────────────────────────┐
│                      AUTH BLOC                               │
├─────────────────────────────────────────────────────────────┤
│  EVENTS                          STATES                      │
├─────────────────────────────────────────────────────────────┤
│  • SendOtpEvent                  • AuthInitial               │
│  • VerifyOtpEvent                • AuthLoading               │
│  • LoginEvent                    • OtpSent                   │
│  • RegisterEvent                 • Authenticated(user)       │
│  • LogoutEvent                   • Unauthenticated           │
│  • CheckAuthStatusEvent          • AuthError(message)        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
         ┌────────────────────────────────────┐
         │        USE CASES                   │
         │  • SendOtpUseCase                  │
         │  • VerifyOtpUseCase                │
         │  • LoginUseCase                    │
         │  • RegisterUseCase                 │
         │  • LogoutUseCase                   │
         └────────────────┬───────────────────┘
                          │
                          ▼
         ┌────────────────────────────────────┐
         │      AUTH REPOSITORY               │
         │  (Business Logic)                  │
         └────────────────┬───────────────────┘
                          │
            ┌─────────────┴─────────────┐
            │                           │
            ▼                           ▼
┌───────────────────────┐   ┌───────────────────────┐
│  Remote Data Source   │   │  Local Data Source    │
│  • MSG91 API calls    │   │  • SharedPreferences  │
│  • HTTP requests      │   │  • SecureStorage      │
└───────────────────────┘   └───────────────────────┘
```

## Error Handling

```
┌─────────────────────────────────────────────────────────────┐
│                    ERROR SCENARIOS                           │
├─────────────────────────────────────────────────────────────┤
│  1. Invalid Phone Number                                     │
│     → Show validation error below text field                 │
│                                                              │
│  2. Network Error (No Internet)                              │
│     → Show "No internet connection" snackbar                 │
│                                                              │
│  3. OTP Send Failed                                          │
│     → Show "Failed to send OTP" snackbar                     │
│     → Allow user to retry                                    │
│                                                              │
│  4. Invalid OTP                                              │
│     → Show "Invalid OTP" snackbar                            │
│     → Keep user on OTP page                                  │
│     → Allow resend after timer                               │
│                                                              │
│  5. OTP Expired                                              │
│     → Show "OTP expired" snackbar                            │
│     → Enable "Resend OTP" immediately                        │
│                                                              │
│  6. Backend Error (500)                                      │
│     → Show "Server error. Please try again" snackbar         │
│                                                              │
│  7. Session Expired                                          │
│     → Clear local storage                                    │
│     → Navigate to login page                                 │
└─────────────────────────────────────────────────────────────┘
```

## Key Features Implemented

### ✅ From test-user-id Branch
1. **Animated Splash Screen**
   - Typing effect for "DREAM247"
   - Blinking cursor animation
   - Gradient purple background
   - Auto-login check

2. **Professional Login UI**
   - Clean phone input
   - Real-time validation
   - Modern gradient design
   - Smooth transitions

3. **6-Digit PIN OTP Input**
   - Using `pin_code_fields` package
   - Individual digit boxes
   - Auto-focus next field
   - Visual feedback

4. **Countdown Timer**
   - 60-second countdown
   - Visual timer display
   - Disables resend until 0
   - Auto-enables resend button

5. **BLoC State Management**
   - Reactive state updates
   - Clean separation of concerns
   - Easy to test
   - Type-safe events/states

6. **Session Persistence**
   - Encrypted token storage
   - Auto-login on restart
   - Unified shop/fantasy session
   - Proper cleanup on logout

7. **Error Handling**
   - User-friendly messages
   - Network error handling
   - OTP validation
   - Retry mechanisms

## Navigation Routes

```
RouteNames.splash           → /
RouteNames.login            → /login
RouteNames.register         → /register
RouteNames.otpVerification  → /otp-verification
RouteNames.home             → /home

[With GoRouter - Type-safe navigation]
```

## Dependencies Used

```yaml
pin_code_fields: ^8.0.1      # PIN input UI
flutter_bloc: ^8.1.3         # State management
equatable: ^2.0.5            # Value equality
get_it: ^7.6.0               # Dependency injection
dartz: ^0.10.1               # Functional programming
go_router: ^12.1.3           # Navigation
shared_preferences: ^2.2.0   # Local storage
flutter_secure_storage: ^9.0.0 # Encrypted storage
dio: ^5.9.0                  # HTTP client
```

---

**Status**: ✅ COMPLETE AND READY FOR TESTING

**Every screen and function works exactly like test-user-id branch!**
