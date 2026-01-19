# 📋 Step-by-Step Diagnostic Checklist

## **5-MINUTE DIAGNOSIS PROTOCOL**

### Step 1: Run the App (1 minute)
- [ ] Start app in debug mode
- [ ] Navigate to any screen showing products (Best Sellers, Popular Products, etc.)
- [ ] **Open Flutter console in VS Code**

### Step 2: Check Console Logs (2 minutes)
Search for logs starting with `[PRODUCT_SERVICE]` or `[PRODUCT_MODEL]`

**What to look for:**
```
Look for:
[PRODUCT_SERVICE] Fetched X products
[PRODUCT_SERVICE] First product JSON: {...}
[PRODUCT_MODEL] Product: NAME, Image URL: URL
```

**Copy exact output** (especially the Image URL line)

### Step 3: Try Clicking a Product (1 minute)
- [ ] Click on any product card
- [ ] Does it navigate to product details? YES / NO
- [ ] If NO: Check console for any errors
- [ ] Check if OutlinedButton is disabled or greyed out

### Step 4: Note All Findings (1 minute)
Write down:
- [ ] Are images showing? YES / NO
- [ ] What do logs show for image URL?
- [ ] Did product card navigate on click? YES / NO
- [ ] Any error messages in console?

---

## **DETAILED INVESTIGATION (If Step 1-4 Not Enough)**

### Investigation A: Image URL Issue

**Check if image URLs are in GraphQL response:**

1. Open ProductService console logs
2. Look for line: `[PRODUCT_SERVICE] First product JSON: {...}`
3. Check if this JSON includes: `"image": {"url": "https://..."}`

**Result:**
- [ ] URL present and valid (https://...) → Navigation issue (proceed to B)
- [ ] URL is empty ("image": {"url": ""}) → Hygraph issue (Step 5 below)
- [ ] URL field missing entirely → GraphQL query issue (Step 6 below)

### Investigation B: Navigation Issue

**Test if OutlinedButton is clickable:**

1. Add this logging to best_sellers.dart (line 89):
```dart
press: () {
  print('🎯 [DEBUG] Product clicked!');
  print('🎯 [DEBUG] Product ID: ${_products[index].id}');
  print('🎯 [DEBUG] Product Name: ${_products[index].title}');
  if (_products[index].id == null || _products[index].id!.isEmpty) {
    print('❌ [ERROR] Product ID is NULL or empty!');
    return;
  }
  print('🎯 [DEBUG] Navigating to: /shop/product/${_products[index].id}');
  context.push('/shop/product/${_products[index].id}',
      extra: {'product': _products[index]});
},
```

2. Click product card again
3. Check console for these debug logs
4. Note all output

**Result:**
- [ ] Click logs appear → Button is clickable ✅
- [ ] No click logs appear → Button not responding (UI issue)
- [ ] Product ID is NULL → Data issue in Hygraph

### Investigation C: Hygraph Data Issue

1. Open Hygraph Dashboard
2. Go to Content → Products
3. For first product, check:
   - [ ] Does it have an ID field value? (Show: YES / NO)
   - [ ] Does image field have image attached? (Show: YES / NO)
   - [ ] Is product published? (Show: YES / NO)
   - [ ] Can you see thumbnail of image? (Show: YES / NO)

**Copy product details:**
- Product ID: ___________________
- Product Name: ___________________
- Image Status: ___________________

---

## **ISSUE ROOT CAUSE DECISION TREE**

```
START
  ↓
Images showing?
├─ YES → Button clickable?
│   ├─ YES → ✅ ISSUE RESOLVED (both working)
│   └─ NO → 🔧 FIX: Navigation issue in app
│           (Check Investigation B)
│
└─ NO → Is image URL in logs?
    ├─ YES (but not displaying) → 🔧 URL accessibility issue
    │                           (Paste URL in browser)
    └─ NO (logs show empty) → 🔧 FIX: Images missing in Hygraph
                             (Upload images in Hygraph)
```

---

## **QUICK FIXES FOR EACH ROOT CAUSE**

### 🔧 Fix #1: Images Missing in Hygraph
**Symptoms:** Logs show empty image URLs

**Fix:**
1. Go to Hygraph Dashboard
2. Open each product
3. Click "image" field
4. Upload/attach image
5. Publish product
6. Refresh app

**Time:** 5 minutes

### 🔧 Fix #2: Image URLs Not Accessible  
**Symptoms:** Logs show URLs but images show error icon

**Fix:**
1. Copy image URL from logs
2. Paste in browser address bar
3. If 404/403 → URL is broken
4. Go to Hygraph and verify image link works
5. May need to re-upload images

**Time:** 10 minutes

### 🔧 Fix #3: Product IDs are Null
**Symptoms:** Debug logs show product ID is null/empty

**Fix:**
1. Go to Hygraph
2. Check if Product model has ID field
3. Ensure all products have ID value
4. If not, re-sync/republish products

**Time:** 5 minutes

### 🔧 Fix #4: OutlinedButton Not Clickable
**Symptoms:** Click logs don't appear in console

**Fix:**
1. Check if button is disabled (greyed out)
2. Verify press callback is not null
3. In best_sellers.dart, ensure this line exists:
   ```dart
   onPressed: widget.press,
   ```
4. Check for any GestureDetector above button blocking taps

**Time:** 5 minutes

---

## **EVIDENCE TO COLLECT**

When reporting issue, provide:

1. **Console Logs** (copy-paste):
   ```
   Paste [PRODUCT_SERVICE] logs here:
   ___________________________________
   
   Paste [PRODUCT_MODEL] logs here:
   ___________________________________
   ```

2. **Debug Test Results**:
   - Images visible? [ ] YES  [ ] NO
   - Product IDs null? [ ] YES  [ ] NO  [ ] Unknown
   - Button clickable? [ ] YES  [ ] NO  [ ] Unknown
   - Navigation works? [ ] YES  [ ] NO  [ ] Unknown

3. **Hygraph Status**:
   - Products have images? [ ] YES  [ ] NO  [ ] Partially
   - All published? [ ] YES  [ ] NO  [ ] Partially
   - Image URLs accessible? [ ] YES  [ ] NO  [ ] Unknown

---

## **EXPECTED FINDINGS BY ISSUE TYPE**

### If "No Images" Issue:
```
Expected Findings:
✓ Logs show: [PRODUCT_SERVICE] Fetched 5 products
✓ Logs show: [PRODUCT_MODEL] Product: T-Shirt, Image URL: 
  (Note: Image URL is EMPTY after colon)
✓ Product cards show error icon
✓ But buttons ARE clickable
✓ Hygraph products exist but image field empty
```

### If "Can't Click" Issue:
```
Expected Findings:
✓ Logs show: [PRODUCT_SERVICE] Fetched 5 products
✓ Logs show valid image URLs
✓ Images ARE displaying correctly
✓ But clicking does nothing
✓ No click debug logs appear
✓ Button might be disabled or transparent overlay present
```

### If "Everything Works":
```
Expected Findings:
✓ Images displaying in all product cards
✓ Product IDs not null in logs
✓ Click logs appear when tapping
✓ Navigation to product details works
✓ Back button works
✓ No console errors
```

---

## **NEXT ACTIONS BASED ON FINDINGS**

| Finding | Action | Est. Time |
|---------|--------|-----------|
| Empty image URLs in logs | Upload images to Hygraph products | 5 min |
| Image URLs in logs but not displaying | Check URL accessibility, might need CDN fix | 10 min |
| Product IDs null | Verify Hygraph product schema, re-publish | 5 min |
| Button not clickable, click logs don't appear | Debug UI overlays, check press callback | 10 min |
| Everything works | Remove debug logging, commit changes | 2 min |

---

## **TROUBLESHOOTING REFERENCES**

- **Product Model:** [lib/features/shop/models/product_model.dart](lib/features/shop/models/product_model.dart)
- **Product Service:** [lib/features/shop/services/product_service.dart](lib/features/shop/services/product_service.dart)
- **Best Sellers Component:** [lib/features/shop/screens/home/views/components/best_sellers.dart](lib/features/shop/screens/home/views/components/best_sellers.dart)
- **Product Card:** [lib/features/shop/components_lib/product/product_card.dart](lib/features/shop/components_lib/product/product_card.dart)
- **Routes Config:** [lib/config/routes/app_router.dart](lib/config/routes/app_router.dart)

---

## **CHECKPOINTS**

- [ ] Checkpoint 1: Images in Hygraph? (YES to proceed)
- [ ] Checkpoint 2: Console logs show data? (YES to proceed)
- [ ] Checkpoint 3: Image URLs in logs? (YES = images should show)
- [ ] Checkpoint 4: Buttons clickable? (YES = navigation should work)
- [ ] Checkpoint 5: Navigation works? (YES = ISSUE FIXED ✅)

**If stuck at any checkpoint, refer to Investigation section above**
