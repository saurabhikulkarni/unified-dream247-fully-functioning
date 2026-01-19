# 📝 Logging Modifications Reference

## Files Already Modified with Debug Logging

### 1. ProductService: [lib/features/shop/services/product_service.dart](lib/features/shop/services/product_service.dart)

**Lines 10-45 - getAllProducts() method has:**

```dart
// Logging already added:
print('[PRODUCT_SERVICE] GraphQL Exception: ${result.exception}');
print('[PRODUCT_SERVICE] No products data returned');
print('[PRODUCT_SERVICE] Fetched ${productsJson.length} products');
print('[PRODUCT_SERVICE] First product JSON: ${productsJson.first}');
```

**Expected output in console:**
```
[PRODUCT_SERVICE] Fetched 5 products
[PRODUCT_SERVICE] First product JSON: {id: "xyz", productName: "T-Shirt", image: {url: "https://..."}}
```

---

### 2. ProductModel: [lib/features/shop/models/product_model.dart](lib/features/shop/models/product_model.dart)

**Lines 28-35 - fromJson() factory has:**

```dart
// Logging already added:
print('[PRODUCT_MODEL] Product: ${json['productName']}, Image URL: $imageUrl');
```

**Expected output in console:**
```
[PRODUCT_MODEL] Product: T-Shirt, Image URL: https://ap-south-1.cdn.hygraph.com/abc123.jpg
[PRODUCT_MODEL] Product: Jeans, Image URL: 
[PRODUCT_MODEL] Product: Shoes, Image URL: https://ap-south-1.cdn.hygraph.com/def456.jpg
```

**Interpretation:**
- If URL is present: ✅ Image should display
- If URL is empty: ❌ Image won't show (Hygraph issue)

---

## Optional: Additional Debug Logging You Can Add

### Add Navigation Debug Logging

**File:** [lib/features/shop/screens/home/views/components/best_sellers.dart](lib/features/shop/screens/home/views/components/best_sellers.dart)

**Location:** Around line 89 where ProductCard is created

**Current code:**
```dart
press: () {
  context.push('/shop/product/${_products[index].id}',
      extra: {'product': _products[index]});
},
```

**Enhanced with logging:**
```dart
press: () {
  print('🎯 [BEST_SELLERS] Product clicked: ${_products[index].title}');
  print('🎯 [BEST_SELLERS] Product ID: ${_products[index].id}');
  print('🎯 [BEST_SELLERS] Product image: ${_products[index].image}');
  
  if (_products[index].id == null || _products[index].id!.isEmpty) {
    print('❌ [BEST_SELLERS] ERROR: Product ID is NULL or empty!');
    return;
  }
  
  final route = '/shop/product/${_products[index].id}';
  print('🎯 [BEST_SELLERS] Navigating to: $route');
  
  try {
    context.push(route, extra: {'product': _products[index]});
    print('✅ [BEST_SELLERS] Navigation successful');
  } catch (e) {
    print('❌ [BEST_SELLERS] Navigation error: $e');
  }
},
```

---

### Add Button Click Detection

**File:** [lib/features/shop/components_lib/product/product_card.dart](lib/features/shop/components_lib/product/product_card.dart)

**Location:** Line 112 where OutlinedButton is created

**Current code:**
```dart
OutlinedButton(
  onPressed: widget.press,
  style: OutlinedButton.styleFrom(...),
  child: Column(...),
),
```

**Enhanced with debug:**
```dart
OutlinedButton(
  onPressed: widget.press != null ? () {
    print('🔘 [PRODUCT_CARD] Button pressed for: ${widget.title}');
    widget.press?.call();
  } : null,
  style: OutlinedButton.styleFrom(...),
  child: Column(...),
),
```

---

### Add Image Load Logging

**File:** [lib/features/shop/components_lib/network_image_with_loader.dart](lib/features/shop/components_lib/network_image_with_loader.dart)

**Location:** In constructor or build method

**Add at start of class:**
```dart
@override
void initState() {
  super.initState();
  print('🖼️ [NETWORK_IMAGE] Loading image: $imageUrl');
  if (imageUrl.isEmpty) {
    print('⚠️ [NETWORK_IMAGE] WARNING: Image URL is empty!');
  }
}
```

---

## Console Log Interpretation Guide

### Log Pattern 1: Image URLs Empty ❌
```
[PRODUCT_SERVICE] Fetched 5 products
[PRODUCT_SERVICE] First product JSON: {id: "1", productName: "T-Shirt", image: {url: null}}
[PRODUCT_MODEL] Product: T-Shirt, Image URL: 
[PRODUCT_MODEL] Product: Jeans, Image URL: 
```

**Diagnosis:** Image field is null in Hygraph response
**Action:** Upload images to products in Hygraph

---

### Log Pattern 2: Image URLs Present ✅
```
[PRODUCT_SERVICE] Fetched 5 products
[PRODUCT_SERVICE] First product JSON: {id: "1", productName: "T-Shirt", image: {url: "https://ap-south-1.cdn..."}}
[PRODUCT_MODEL] Product: T-Shirt, Image URL: https://ap-south-1.cdn.hygraph.com/abc123.jpg
[PRODUCT_MODEL] Product: Jeans, Image URL: https://ap-south-1.cdn.hygraph.com/def456.jpg
```

**Diagnosis:** Image URLs are being fetched correctly
**Action:** Check why images aren't displaying (URL accessibility issue)

---

### Log Pattern 3: No Products Loaded ❌
```
[PRODUCT_SERVICE] GraphQL Exception: SocketException: Failed host lookup...
[PRODUCT_SERVICE] No products data returned
```

**Diagnosis:** Can't reach Hygraph API
**Action:** Check internet connection, verify Hygraph endpoint

---

### Log Pattern 4: Navigation Working ✅
```
🎯 [BEST_SELLERS] Product clicked: T-Shirt
🎯 [BEST_SELLERS] Product ID: abc123
🎯 [BEST_SELLERS] Navigating to: /shop/product/abc123
✅ [BEST_SELLERS] Navigation successful
```

**Diagnosis:** Product card click and navigation working
**Action:** Issue is only image display

---

### Log Pattern 5: Navigation Failed ❌
```
🎯 [BEST_SELLERS] Product clicked: T-Shirt
🎯 [BEST_SELLERS] Product ID: 
❌ [BEST_SELLERS] ERROR: Product ID is NULL or empty!
```

**Diagnosis:** Product doesn't have ID from Hygraph
**Action:** Check Hygraph product schema and data

---

## How to Read JSON Response Logs

When you see:
```
[PRODUCT_SERVICE] First product JSON: {id: "xyz", productName: "...", image: {url: "..."}}
```

**Structure breakdown:**
```
{
  "id": "xyz",                    ← Product ID
  "productName": "T-Shirt",       ← Product name
  "image": {                      ← Image object
    "url": "https://..."          ← Image URL (what we need!)
  }
}
```

**Image variations you might see:**

✅ **Good - Nested object with URL:**
```
"image": {
  "url": "https://ap-south-1.cdn.hygraph.com/abc123.jpg"
}
```

✅ **Also good - Direct string:**
```
"image": "https://ap-south-1.cdn.hygraph.com/abc123.jpg"
```

❌ **Bad - URL is null:**
```
"image": {
  "url": null
}
```

❌ **Bad - Image field missing:**
```json
{"id": "xyz", "productName": "...", "price": 100}
// No "image" field at all
```

❌ **Bad - Empty string:**
```
"image": {
  "url": ""
}
```

---

## Search Console for These Prefixes

**In VS Code Debug Console, search for:**
- `[PRODUCT_SERVICE]` → Product fetching
- `[PRODUCT_MODEL]` → Image parsing
- `[BEST_SELLERS]` → Component rendering (if added)
- `🎯` → Navigation events (if added)
- `🖼️` → Image loading (if added)
- `❌` → Errors (if added)
- `✅` → Success (if added)

---

## Quick Debug Setup

To see all product-related logs:

1. **Open Flutter Console** (VS Code: Debug Console tab)
2. **Search field:** Type `PRODUCT` or `BEST_SELLERS`
3. **Hit Enter** - will highlight all matching logs
4. **Scroll up/down** to see all logs
5. **Expand JSON** by clicking on log entries to see full details

---

## Expected Log Sequence When App Starts

```
1. [PRODUCT_SERVICE] Fetched 5 products
2. [PRODUCT_SERVICE] First product JSON: {...}
3. [PRODUCT_MODEL] Product: T-Shirt, Image URL: https://...
4. [PRODUCT_MODEL] Product: Jeans, Image URL: https://...
5. [PRODUCT_MODEL] Product: Shoes, Image URL:    ← Empty!
6. [PRODUCT_MODEL] Product: Hat, Image URL: https://...
7. [PRODUCT_MODEL] Product: Gloves, Image URL: https://...

Screen loads: Best Sellers shows 5 items
- T-Shirt: Image visible ✅
- Jeans: Image visible ✅
- Shoes: Error icon (no image URL)
- Hat: Image visible ✅
- Gloves: Image visible ✅
```

---

## Removing Debug Logging (Cleanup)

When issue is fixed, remove or comment out:

**In product_service.dart:**
```dart
// Cleanup - remove these lines:
print('[PRODUCT_SERVICE] GraphQL Exception: ${result.exception}');
print('[PRODUCT_SERVICE] No products data returned');
print('[PRODUCT_SERVICE] Fetched ${productsJson.length} products');
print('[PRODUCT_SERVICE] First product JSON: ${productsJson.first}');
```

**In product_model.dart:**
```dart
// Cleanup - remove this line:
print('[PRODUCT_MODEL] Product: ${json['productName']}, Image URL: $imageUrl');
```

---

## Debugging Tools

**Flutter Inspector:**
- Shows widget tree
- Can inspect OutlinedButton state (enabled/disabled)
- Can check if UI overlays are blocking taps

**Network Tab (if available):**
- Shows GraphQL requests/responses
- Can inspect actual Hygraph response for image URLs
- Can verify API connectivity

**Hygraph Dashboard:**
- Direct inspection of product data
- Can see if images are uploaded
- Can test image URLs directly

---

## Common Console Typos in Logs

If you see these, it means something is wrong with logging setup:
- `[PRODUCT_SERVIE]` → Typo in code
- `[PRODUCT_MODEL]` missing → Not called
- `Image URL: undefined` → Image URL is actually undefined, not null
- `[object Object]` → Trying to print object instead of URL string

If any of these appear, check that logging lines are exactly as shown above.
