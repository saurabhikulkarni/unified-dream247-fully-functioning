# ⚡ ACTION CARD - Do This Now

**Print this card and follow along**

---

## 🎯 PHASE 1: Diagnosis (5 Minutes)

### Step 1️⃣ Run the App
```
flutter run
```
✓ Wait for app to fully load

### Step 2️⃣ Navigate to Product Listing
- Tap on "Best Sellers" or any product section
- Wait for products to load
- ✓ Note: Do you see product images? YES ⭕ NO ⭕

### Step 3️⃣ Open Flutter Console
- In VS Code
- View → Debug Console
- Or press Ctrl+Shift+J

### Step 4️⃣ Search for Logs
- In console search box, type: `PRODUCT_MODEL`
- Look for lines that say:
```
[PRODUCT_MODEL] Product: T-Shirt, Image URL: [LOOK HERE]
```

### Step 5️⃣ Write Down What You See
**Image URL is:** 
- ⭕ Empty (nothing after "Image URL: ")
- ⭕ Has URL (https://ap-south-1.cdn...)
- ⭕ Not found (no [PRODUCT_MODEL] logs)

**Images are showing in UI:**
- ⭕ YES (I see product images)
- ⭕ NO (I see error icons or blank)

---

## 🔍 PHASE 2: Root Cause Identification (2 Minutes)

**Match your findings below:**

### Case A: Empty URLs + No Images ✗
```
[PRODUCT_MODEL] Product: T-Shirt, Image URL: 
[PRODUCT_MODEL] Product: Jeans, Image URL: 
```
**DIAGNOSIS:** Images not in Hygraph
**ACTION:** Go to Phase 3A

### Case B: URLs Present + Images Showing ✓
```
[PRODUCT_MODEL] Product: T-Shirt, Image URL: https://ap-south-1.cdn.hygraph.com/abc.jpg
```
**DIAGNOSIS:** Images working! Test clicking now
**ACTION:** Go to Phase 3B

### Case C: URLs Present + No Images ✗
```
[PRODUCT_MODEL] Product: T-Shirt, Image URL: https://ap-south-1.cdn.hygraph.com/abc.jpg
// But no images show in app
```
**DIAGNOSIS:** URL format or accessibility issue
**ACTION:** Go to Phase 3C

### Case D: No ProductModel Logs ✗
```
// Logs not appearing at all
```
**DIAGNOSIS:** Products not fetching or parsing
**ACTION:** Check for [PRODUCT_SERVICE] errors

---

## 🛠️ PHASE 3: Apply Fix

### 3A: Empty Image URLs (Most Likely - 80%)

**Action:**
1. Go to https://app.hygraph.com/
2. Click Content → Products
3. Open first product
4. Find "image" field
5. Click upload button
6. Select/upload image
7. Click Publish
8. Repeat for other products
9. Go back to app, refresh (pull down)

**Verify:** Console should now show:
```
[PRODUCT_MODEL] Product: T-Shirt, Image URL: https://...
```

**Time:** 5 minutes
**Success Rate:** 95%

---

### 3B: Images Working - Test Navigation

**Action:**
1. In app, click on any product card
2. Does it open product details? 
   - YES ✓ → ISSUE FIXED! ✅
   - NO ✗ → Continue to 3D

**Time:** 1 minute

---

### 3C: URL Present But Not Showing

**Action:**
1. Copy URL from console
2. Open browser
3. Paste URL in address bar
4. Does image show?
   - YES ✓ → URL works, may be other issue
   - NO ✗ → URL is broken

**If NO (URL broken):**
1. Go to Hygraph
2. Check image field for this product
3. Delete and re-upload image
4. Refresh app

**Time:** 5 minutes

---

### 3D: Navigation Not Working

**Action:**
1. Open [lib/features/shop/screens/home/views/components/best_sellers.dart](lib/features/shop/screens/home/views/components/best_sellers.dart)
2. Around line 89, replace:
```dart
press: () {
  context.push('/shop/product/${_products[index].id}',
      extra: {'product': _products[index]});
},
```

With:
```dart
press: () {
  print('DEBUG: Clicked ${_products[index].title}');
  print('DEBUG: ID = ${_products[index].id}');
  context.push('/shop/product/${_products[index].id}',
      extra: {'product': _products[index]});
},
```

3. Click product again
4. Check console - do debug logs appear?
   - YES ✓ → Button works, check route config
   - NO ✗ → Button might be disabled

**Time:** 5 minutes

---

## ✅ VERIFICATION Checklist

After applying fix, verify:

- [ ] Product images display in UI
- [ ] No error icons on product cards
- [ ] Clicking product navigates to details
- [ ] Back button works
- [ ] No console errors
- [ ] Console shows valid image URLs

**If all checked:** ✅ ISSUE FIXED

**If not all checked:** Go to Phase 3 for remaining issues

---

## 🎯 Expected Timeline

| Phase | Time | Task |
|-------|------|------|
| 1 | 5 min | Diagnosis |
| 2 | 2 min | Identify issue |
| 3 | 5-15 min | Apply fix |
| Verify | 1 min | Check results |
| **Total** | **13-23 min** | **Complete** |

---

## 📝 Notes Section

**What I found:**
```
________________________________
________________________________
________________________________
________________________________
```

**Issue identified:**
```
________________________________
________________________________
```

**Fix applied:**
```
________________________________
________________________________
```

**Result:**
- [ ] Fixed ✅
- [ ] Partially fixed ⚠️
- [ ] Still broken ❌

---

## 🆘 If Stuck

1. Read: QUICK_PRODUCT_FIX.md (2 min)
2. Read: DIAGNOSTIC_CHECKLIST.md (5 min)
3. Search console for `[PRODUCT_SERVICE]` errors
4. Screenshot error and check LOGGING_REFERENCE.md

---

## 🚀 Quick Commands

**Run app:**
```bash
flutter run
```

**Hot reload (after code changes):**
```bash
r  (in terminal)
```

**Hot restart (full reload):**
```bash
R  (in terminal)
```

**Clear cache and rebuild:**
```bash
flutter clean && flutter pub get && flutter run
```

---

## 📱 Navigation Path to Test

```
App Start
  ↓
Home Screen
  ↓
Best Sellers Section (Product Listing)
  ↓
Click Product Card
  ↓
ProductDetailsScreen (Should open)
  ↓
Tap Back
  ↓
Return to Best Sellers
```

All of above should work smoothly.

---

## 🎓 Remember

1. **Most likely issue:** Images not in Hygraph (80%)
2. **Symptom:** Empty image URLs in console logs
3. **Fix:** Upload images in Hygraph
4. **Time:** 5 minutes
5. **Confidence:** 95%

---

## ✍️ Sign-off

**Started:** ____________ (time)  
**Issue Identified:** ____________________________  
**Fix Applied:** ________________________________  
**Completed:** ____________ (time)  
**Result:** ✅ / ⚠️ / ❌  

---

**GOOD LUCK! 🚀 You got this!**

*Most cases are fixed by Phase 3A in < 15 minutes*
