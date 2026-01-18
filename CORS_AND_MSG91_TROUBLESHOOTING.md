# CORS & MSG91 OTP - Troubleshooting Guide

## 🔴 Current Issues

### Issue #1: CORS Policy Error
```
❌ Access to fetch at 'http://localhost:3000/api/auth/send-otp' 
   from origin 'http://localhost:59030' has been blocked by CORS policy: 
   Response to preflight request doesn't pass access control check: 
   No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

**What is CORS?**
- CORS = Cross-Origin Resource Sharing
- It's a security mechanism that prevents browser from accessing APIs from different origins
- `localhost:59030` (your local dev) is a different origin than `brighthex-dream-24-7-backend-psi.vercel.app` (production backend)

**Why is it happening NOW?**
- The backend API is not configured to allow requests from `localhost` (local development)
- This typically works for production builds but fails during local development

---

## ✅ Solutions

### Solution 1: Fix Backend CORS Configuration (REQUIRED FOR PRODUCTION)

Your backend needs to add CORS headers. The backend should respond with:

```
Access-Control-Allow-Origin: http://localhost:59030
Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
```

**Backend implementation example (Express.js):**
```javascript
const cors = require('cors');

app.use(cors({
  origin: [
    'http://localhost:3000',           // Local dev
    'http://localhost:59030',          // Flutter web dev
    'https://yourdomain.com',          // Production domain
    'https://brighthex-dream-24-7.vercel.app' // Your production frontend
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

**Backend Configuration File (Node.js):**
```javascript
// middleware/cors.js
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || [
    'http://localhost:3000',
    'http://localhost:59030', // Flutter web dev
    'http://192.168.1.100:59030', // Local network access
  ],
  credentials: true,
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
  allowedHeaders: 'Content-Type,Authorization',
};

module.exports = corsOptions;
```

---

### Solution 2: Use Backend Proxy (Recommended for Development)

Instead of calling the backend API directly from Flutter frontend, use a proxy:

**Frontend Change:**
```dart
// lib/features/shop/services/msg91_service.dart
// Change from direct backend call to local proxy
// OLD:
static const String baseUrl = 
    'http://localhost:3000/api';

// NEW: Use your local/proxy backend
static const String baseUrl = 
    'http://localhost:3000/api'; // Your backend server (handles CORS)
```

**Backend creates CORS-safe proxy to MSG91:**
```javascript
// Backend route handler
app.post('/api/auth/send-otp', corsMiddleware, async (req, res) => {
  // Backend handles MSG91 call (no CORS issues)
  // Frontend calls this endpoint (CORS handled by backend)
  const response = await msg91Service.sendOtp(req.body.mobileNumber);
  res.json(response); // Add CORS headers here
});
```

---

### Solution 3: Temporary Development Workaround

For local development testing, use browser developer tools to disable CORS:
- Chrome: `--disable-web-security` flag
- Firefox: Disable CORS in about:config
- **NOT recommended for production**

---

## 🔧 Frontend Improvements Made

### 1. Fixed GetIt Dependency Injection
```dart
// Added missing registration in injection_container.dart
getIt.registerLazySingleton(() => ApiImplWithAccessToken());
```

**Error that was fixed:**
```
❌ GetIt: Object/factory with type ApiImplWithAccessToken is not registered inside GetIt
```

### 2. Improved Error Handling in MSG91Service
```dart
// Better error messages for different failure scenarios
if (e.toString().contains('CORS') || e.toString().contains('Failed to fetch')) {
  errorMessage = 'Network error: Please check your internet connection or try again later.';
} else if (e.toString().contains('Connection refused')) {
  errorMessage = 'Backend service unavailable. Please try again later.';
} else if (e.toString().contains('TimeoutException')) {
  errorMessage = 'Request timed out. Please try again.';
}
```

---

## 📋 Debugging Checklist

### ✅ Frontend Issues (Already Fixed)
- [x] GetIt registration for ApiImplWithAccessToken
- [x] Error handling for CORS errors
- [x] Proper error messages to users

### ⚠️ Backend Configuration (MUST BE FIXED)
- [ ] Backend CORS middleware configured
- [ ] CORS headers added to `/api/auth/send-otp`
- [ ] CORS headers added to `/api/auth/verify-otp`
- [ ] Tested with `http://localhost:59030` origin

### 🧪 Testing Steps

1. **Check if backend is running:**
   ```bash
   curl -X OPTIONS http://localhost:3000/api/auth/send-otp \
     -H "Origin: http://localhost:59030" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type"
   ```

2. **Expected response headers:**
   ```
   Access-Control-Allow-Origin: http://localhost:59030
   Access-Control-Allow-Methods: POST, OPTIONS
   Access-Control-Allow-Headers: Content-Type
   ```

3. **If not present, that's the issue!**

---

## 🚀 Production Deployment

When deploying to production:

1. **Update backend CORS configuration:**
   ```javascript
   const allowedOrigins = [
     'https://yourdomain.com',
     'https://www.yourdomain.com',
     'https://app.yourdomain.com'
   ];
   ```

2. **Update MSG91Config if needed:**
   ```dart
   // lib/config/msg91_config.dart
   static const String baseUrl = 
       'https://yourdomain.com/api'; // Your production backend
   ```

3. **Test thoroughly before launch**

---

## 📞 Next Steps

1. **Inform backend team** about the CORS requirements
2. **Request backend to add CORS headers** for `/api/auth/send-otp` and `/api/auth/verify-otp`
3. **Test locally** once backend CORS is configured
4. **Verify MSG91 OTP is working** with real phone numbers

---

## 📚 Resources

- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Express CORS Middleware](https://expressjs.com/en/resources/middleware/cors.html)
- [Vercel CORS Guide](https://vercel.com/docs/concepts/functions/serverless-functions/api-routes#cors)

---

**Last Updated:** January 18, 2026  
**Status:** ⚠️ Requires Backend CORS Configuration
