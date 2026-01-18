# Hygraph Schema Configuration - OTP Verification Fix

## 🎯 Goal
Configure Hygraph so the backend can find users by mobile number during OTP verification.

---

## ⚠️ Current Error
```
Field "mobileNumber" is not defined by type "UserDetailWhereUniqueInput"
```

This happens because `mobileNumber` is not configured as a **searchable field** in Hygraph.

---

## 🔧 Step-by-Step Configuration

### Step 1: Access Hygraph Dashboard

1. Go to **https://app.hygraph.com/**
2. Log in with your account
3. Select your project: **brighthex-dream-24-7** (or your project name)
4. You should see the project dashboard

---

### Step 2: Navigate to Schema

1. Click **"Schema"** in the left sidebar
2. You should see a list of models: `UserDetail`, `Shop`, `Product`, etc.
3. Click on **`UserDetail`** model

---

### Step 3: Configure mobileNumber Field

#### Option A: Make it a Unique Identifier (Best for OTP)

1. In the **UserDetail** model, find the **`mobileNumber`** field
2. Click on the **`mobileNumber`** field to edit it
3. Look for these options in the field settings:

   **Toggle these ON:**
   - ✅ **"Use as unique identifier"** (Makes it queryable for `where` clauses)
   - ✅ **"Make queryable"** (Allows searching/filtering)
   - ✅ **"Sortable"** (Optional, for sorting)

4. **Save** the field

---

#### Option B: Alternative - Just Make it Queryable

If you don't want to use it as unique identifier:

1. Click on **`mobileNumber`** field
2. Look for **"Advanced"** or **"Queryability"** section
3. Enable:
   - ✅ **"Make queryable"**
   - ✅ **"Sortable"**

4. **Save**

---

### Step 4: Publish Schema Changes

1. After making changes, look for a **"Publish"** button
2. Click **"Publish"** to apply changes to your content API
3. Wait for the deployment to complete (usually 30 seconds - 2 minutes)

---

## 📸 Visual Guide

```
Hygraph Dashboard Layout:
┌─────────────────────────────────────────────────────┐
│  Projects  │ Schema │ Content │ API │ Settings    │
└─────────────────────────────────────────────────────┘
                    ↓ Click here
             Schema Builder View
    ┌────────────────────────────────┐
    │ Models:                         │
    │  • UserDetail    ← Select this │
    │  • Product                     │
    │  • Shop                        │
    └────────────────────────────────┘
           ↓ Opens
    UserDetail Model Fields:
    ┌─────────────────────────────┐
    │ id             (SystemField)│
    │ username       (String)     │
    │ email          (String)     │
    │ firstName      (String)     │
    │ lastName       (String)     │
    │ mobileNumber   (String)     │ ← Click to configure
    │ refreshToken   (String)     │
    │ modules        (JSON)       │
    └─────────────────────────────┘
```

---

## 🔍 Field Settings to Enable

When you click on **`mobileNumber`** field, you should see:

```
Field Name: mobileNumber
Field Type: String

☑ Required           (Check if not already checked)
☑ Make Queryable     ← ENABLE THIS
☑ Sortable           (Optional)
☑ Use as unique identifier  ← ENABLE THIS (Best for OTP)

Advanced Options:
☑ Make it localized  (Usually OFF)
☑ Hidden from API    (Make sure it's OFF)
```

---

## ✅ Verification Steps

### After Configuration, Test the Query

1. Go to **API Playground** in Hygraph
2. Run this test query:

```graphql
query GetUserByMobile($mobileNumber: String!) {
  userDetails(where: { mobileNumber: $mobileNumber }) {
    id
    mobileNumber
    firstName
    lastName
    username
    refreshToken
    modules
  }
}
```

**Variables:**
```json
{
  "mobileNumber": "9049522492"
}
```

**Expected Response:**
```json
{
  "data": {
    "userDetails": [
      {
        "id": "user123...",
        "mobileNumber": "9049522492",
        "firstName": "Saurabhi",
        "lastName": "Kulkarni",
        "username": "saurabhi",
        "refreshToken": "...",
        "modules": {...}
      }
    ]
  }
}
```

---

## 🚀 After Configuration is Done

Once you've configured the schema:

1. **Publish the changes** in Hygraph
2. **Restart your backend server** (Node.js)
3. **Try OTP flow again** from your Flutter app:
   - Enter mobile number: `9049522492`
   - Click "Send OTP"
   - Enter OTP from SMS
   - Click "Verify"
   - ✅ Should now succeed!

---

## 🐛 Troubleshooting

### Issue: Still getting "Field not defined" error

**Solution:**
1. Check if you published the schema changes
2. Restart backend server after publishing
3. Clear browser cache and retry

### Issue: Query returns empty array

**Solution:**
1. Verify the user record exists with that mobile number in Hygraph
2. Make sure the mobile number format matches exactly (no spaces, country codes, etc.)
3. Check if the field is case-sensitive

### Issue: Can't find the field settings

**Solution:**
1. Make sure you're in the right model (`UserDetail`)
2. Try scrolling down in field settings
3. Look for "Advanced" section if options are collapsed

---

## 📋 Hygraph Schema Checklist

- [ ] Logged into Hygraph dashboard
- [ ] Selected correct project: `brighthex-dream-24-7`
- [ ] Navigated to `Schema` → `UserDetail` model
- [ ] Found `mobileNumber` field
- [ ] Enabled "Make Queryable"
- [ ] Enabled "Use as unique identifier" (optional but recommended)
- [ ] Clicked "Save" on the field
- [ ] Published schema changes
- [ ] Verified query works in API Playground
- [ ] Restarted backend server
- [ ] Tested OTP flow in Flutter app

---

## 📞 Quick Reference

**Your Backend Expects:**
```javascript
// Hygraph query structure
query GetUserByMobile($mobileNumber: String!) {
  userDetails(where: { mobileNumber: $mobileNumber }) {
    // fields
  }
}
```

**Mobile Number Format:**
- Should be: `9049522492` (10 digits, no country code)
- NOT: `919049522492` (with country code)

**Backend Location:**
```
D:\shop-backend\brighthex-dream-24-7-backend\routes\auth.js:179
HygraphUserService.findUserByMobile(mobileNumber)
```

---

## 🎓 What This Does

Once configured, the OTP verification flow will work like this:

```
Frontend sends: phone = 9049522492
         ↓
Backend receives OTP verification request
         ↓
Backend queries Hygraph:
  "Find user where mobileNumber = 9049522492"
         ↓
Hygraph finds the user record
         ↓
Backend returns user data to frontend
         ↓
Frontend saves session and redirects to home
         ↓
✅ User is logged in!
```

---

## 📚 Hygraph Documentation

For more detailed info:
- [Hygraph Schema Documentation](https://hygraph.com/docs/schema)
- [Querying by Unique Fields](https://hygraph.com/docs/queries)
- [Content API Reference](https://hygraph.com/docs/content-api)

---

**Last Updated:** January 18, 2026  
**Status:** ⚠️ Awaiting Hygraph Schema Configuration
