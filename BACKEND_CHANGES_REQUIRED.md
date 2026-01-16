# 🔧 BACKEND CHANGES REQUIRED FOR UNIFIED WALLET

**Date**: January 16, 2026  
**Status**: Required for Production  
**Priority**: MEDIUM (Works without it for MVP, needed for persistence)

---

## 📋 QUICK SUMMARY

| Task | Backend | Type | Priority |
|------|---------|------|----------|
| Add WalletTransaction model | Hygraph | Schema | MEDIUM |
| Add shopTokens to Order model | Hygraph | Schema | MEDIUM |
| Add shopTokens to UserDetail | Hygraph | Field | MEDIUM |
| Create WalletTransaction collection | MongoDB | Database | MEDIUM |
| Add deductShopTokens mutation | GraphQL API | Mutation | HIGH |
| Add getWalletBalance query | GraphQL API | Query | HIGH |
| Add getWalletTransactions query | GraphQL API | Query | HIGH |

---

## 🏗️ BACKEND 1: HYGRAPH (CMS)

### **Step 1: Add Fields to UserDetail Model**

**Location**: Hygraph Dashboard → Content Model → UserDetail

**Add These Fields**:

```
Field Name: shopTokens
Type: Float
Default Value: 0
Description: "Current shop tokens balance"

Field Name: totalSpentTokens  
Type: Float
Default Value: 0
Description: "Total tokens ever spent (for analytics)"

Field Name: walletTransactions
Type: Relationship (to WalletTransaction model)
Direction: One-to-Many
Description: "All wallet transactions for this user"
```

**After Changes**:
```graphql
type UserDetail {
  id: ID!
  firstName: String!
  lastName: String!
  username: String!
  mobileNumber: String!
  walletBalance: Float       # Already exists
  shopTokens: Float!         # NEW
  totalSpentTokens: Float!   # NEW
  walletTransactions: [WalletTransaction!]  # NEW relationship
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

---

### **Step 2: Create New WalletTransaction Model**

**Location**: Hygraph Dashboard → Content Model → Create New → WalletTransaction

**Fields**:

```
Field Name: id
Type: ID (auto-generated)

Field Name: userId
Type: String (searchable, indexed)
Description: "User ID reference"

Field Name: type
Type: Enumeration
Enum Values:
  - add_money (user added via Razorpay)
  - purchase (token deduction for purchase)
  - refund (refund/credit)
  - admin_adjustment (admin action)
Description: "Transaction type"

Field Name: amount
Type: Float
Description: "Transaction amount (positive or negative)"

Field Name: description
Type: String
Description: "User-friendly description"

Field Name: orderReference
Type: String (optional)
Description: "Reference to Shop Order ID"

Field Name: paymentMethod
Type: String (optional)
Description: "Payment method used (razorpay, shopTokens, etc)"

Field Name: timestamp
Type: DateTime (auto-generate on create)
Description: "When transaction occurred"

Field Name: status
Type: Enumeration
Enum Values:
  - pending
  - completed
  - failed
  - reversed
Description: "Transaction status"

Field Name: metadata
Type: JSON (optional)
Description: "Additional data (itemName, cartItems, etc)"

Field Name: userDetail
Type: Relationship (to UserDetail model)
Direction: Many-to-One
Description: "Reference to user"
```

**Final Schema**:
```graphql
type WalletTransaction {
  id: ID!
  userId: String!
  userDetail: UserDetail!
  type: TransactionType!           # enum: add_money, purchase, refund, admin_adjustment
  amount: Float!
  description: String!
  orderReference: String
  paymentMethod: String
  timestamp: DateTime!
  status: TransactionStatus!       # enum: pending, completed, failed, reversed
  metadata: JSON
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

---

### **Step 3: Update Order Model**

**Location**: Hygraph Dashboard → Content Model → Order

**Add These Fields**:

```
Field Name: paymentMethod
Type: String
Description: "Payment method used (razorpay, shopTokens)"

Field Name: tokensUsed
Type: Float
Description: "Shop tokens used for this order (if paid with tokens)"
```

**After Changes - Order fields become**:
```graphql
type Order {
  # Existing fields...
  id: ID!
  orderNumber: String!
  userDetail: UserDetail!
  totalAmount: Float!
  orderStatus: OrderStatus!
  address: Address
  items: [OrderItem!]
  createdAt: DateTime!
  updatedAt: DateTime!
  
  # NEW fields:
  paymentMethod: String          # "razorpay", "shopTokens", etc
  tokensUsed: Float             # Amount of tokens used
  transactionReference: String  # Reference to WalletTransaction
}
```

---

## 📝 HYGRAPH MANUAL STEPS (Click-by-Click)

### **Step 1: Add shopTokens to UserDetail**
```
1. Go to Hygraph Dashboard
2. Click "Content Model"
3. Find "UserDetail" → Click it
4. Click "Add Field"
5. Name: shopTokens
   Type: Float
   Default: 0
   Advanced → Mark as searchable
6. Click "Save"
```

### **Step 2: Create WalletTransaction Model**
```
1. Go to Content Model
2. Click "+ Create Model"
3. Name: WalletTransaction
4. Click "Create"
5. Add fields (see list above):
   - userId (String)
   - type (Enum)
   - amount (Float)
   - description (String)
   - orderReference (String, optional)
   - timestamp (DateTime)
   - status (Enum)
   - metadata (JSON, optional)
6. Add Relationship to UserDetail
7. Save all
```

### **Step 3: Update Order Model**
```
1. Go to Content Model
2. Find "Order" → Click it
3. Click "Add Field"
4. Name: paymentMethod
   Type: String
5. Click "Add Field"
6. Name: tokensUsed
   Type: Float
7. Save
```

---

## 🔌 BACKEND 2: GraphQL API Changes

### **Add to graphql_queries.dart**

**File**: `lib/features/shop/services/graphql_queries.dart`

**Add These Queries/Mutations**:

```dart
// ============ WALLET QUERIES & MUTATIONS ============

// Get user wallet balance and tokens
static const String getUserWallet = '''
  query GetUserWallet(\$userId: ID!) {
    userDetail(where: {id: \$userId}) {
      id
      walletBalance
      shopTokens
      totalSpentTokens
    }
  }
''';

// Get wallet transaction history
static const String getWalletTransactions = '''
  query GetWalletTransactions(\$userId: String!, \$first: Int = 50, \$skip: Int = 0) {
    walletTransactions(
      where: {userId: \$userId}
      first: \$first
      skip: \$skip
      orderBy: timestamp_DESC
    ) {
      id
      userId
      type
      amount
      description
      orderReference
      paymentMethod
      timestamp
      status
      metadata
    }
  }
''';

// Deduct shop tokens for purchase
static const String deductShopTokens = '''
  mutation DeductShopTokens(
    \$userId: ID!,
    \$amount: Float!,
    \$orderId: String!,
    \$itemName: String!
  ) {
    updateUserDetail(
      where: {id: \$userId}
      data: {
        shopTokens: {decrement: \$amount}
        totalSpentTokens: {increment: \$amount}
      }
    ) {
      id
      shopTokens
      totalSpentTokens
    }
    
    createWalletTransaction(
      data: {
        userId: \$userId
        type: purchase
        amount: -\$amount
        description: "Purchased \$itemName"
        orderReference: \$orderId
        paymentMethod: "shopTokens"
        timestamp: now
        status: completed
        userDetail: {connect: {id: \$userId}}
      }
    ) {
      id
      userId
      type
      amount
      description
    }
  }
''';

// Add shop tokens from payment
static const String addShopTokens = '''
  mutation AddShopTokens(
    \$userId: ID!,
    \$amount: Float!,
    \$paymentMethod: String = "razorpay"
  ) {
    updateUserDetail(
      where: {id: \$userId}
      data: {shopTokens: {increment: \$amount}}
    ) {
      id
      shopTokens
    }
    
    createWalletTransaction(
      data: {
        userId: \$userId
        type: add_money
        amount: \$amount
        description: "Added \$amount tokens"
        paymentMethod: \$paymentMethod
        timestamp: now
        status: completed
        userDetail: {connect: {id: \$userId}}
      }
    ) {
      id
      userId
      type
      amount
    }
  }
''';

// Get merged transaction history (shop + fantasy)
static const String getMergedTransactionHistory = '''
  query GetMergedTransactionHistory(\$userId: String!, \$first: Int = 100) {
    walletTransactions(
      where: {userId: \$userId}
      first: \$first
      orderBy: timestamp_DESC
    ) {
      id
      type
      amount
      description
      timestamp
      status
      paymentMethod
      orderReference
    }
  }
''';

// Update order with payment method and tokens used
static const String updateOrderPaymentMethod = '''
  mutation UpdateOrderPaymentMethod(
    \$orderId: ID!,
    \$paymentMethod: String!,
    \$tokensUsed: Float
  ) {
    updateOrder(
      where: {id: \$orderId}
      data: {
        paymentMethod: \$paymentMethod
        tokensUsed: \$tokensUsed
      }
    ) {
      id
      paymentMethod
      tokensUsed
    }
  }
''';
```

---

## 📦 BACKEND 3: MongoDB Changes

### **Create Collections**

**Database**: Your MongoDB instance (same as Fantasy)

**Create Collection 1: wallet_transactions**

```javascript
db.createCollection("wallet_transactions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "type", "amount", "description", "timestamp", "status"],
      properties: {
        _id: { bsonType: "objectId" },
        userId: { 
          bsonType: "string",
          description: "User ID (from Hygraph or auth)"
        },
        type: { 
          bsonType: "string",
          enum: ["add_money", "purchase", "refund", "admin_adjustment"],
          description: "Transaction type"
        },
        amount: { 
          bsonType: "double",
          description: "Amount (positive or negative)"
        },
        description: { 
          bsonType: "string",
          description: "Human-readable description"
        },
        orderReference: { 
          bsonType: "string",
          description: "Reference to Shop Order ID (optional)"
        },
        paymentMethod: { 
          bsonType: "string",
          description: "Payment method (razorpay, shopTokens, etc)"
        },
        timestamp: { 
          bsonType: "date",
          description: "When transaction occurred"
        },
        status: { 
          bsonType: "string",
          enum: ["pending", "completed", "failed", "reversed"],
          description: "Transaction status"
        },
        metadata: { 
          bsonType: "object",
          description: "Additional JSON data"
        },
        createdAt: { 
          bsonType: "date",
          description: "Record creation time"
        },
        updatedAt: { 
          bsonType: "date",
          description: "Last update time"
        }
      }
    }
  }
});

// Create indexes for better query performance
db.wallet_transactions.createIndex({ userId: 1 }, { sparse: true });
db.wallet_transactions.createIndex({ userId: 1, timestamp: -1 });
db.wallet_transactions.createIndex({ orderReference: 1 }, { sparse: true });
db.wallet_transactions.createIndex({ status: 1 });
db.wallet_transactions.createIndex({ type: 1 });
```

**Create Collection 2: user_wallets (optional caching)**

```javascript
db.createCollection("user_wallets", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "shopTokens", "totalSpent"],
      properties: {
        _id: { bsonType: "objectId" },
        userId: { 
          bsonType: "string",
          description: "User ID (unique index)"
        },
        shopTokens: { 
          bsonType: "double",
          description: "Current shop token balance"
        },
        gameTokens: { 
          bsonType: "double",
          description: "Current game token balance"
        },
        totalSpent: { 
          bsonType: "double",
          description: "Total tokens ever spent"
        },
        totalAdded: { 
          bsonType: "double",
          description: "Total tokens ever added"
        },
        lastSyncedAt: { 
          bsonType: "date",
          description: "Last sync with Hygraph"
        },
        createdAt: { 
          bsonType: "date"
        },
        updatedAt: { 
          bsonType: "date"
        }
      }
    }
  }
});

// Unique index on userId
db.user_wallets.createIndex({ userId: 1 }, { unique: true });
```

---

## 🔄 MongoDB Manual Steps (CLI)

```bash
# 1. Connect to MongoDB
mongosh "mongodb+srv://username:password@cluster.mongodb.net/dream247"

# 2. Create wallet_transactions collection
db.createCollection("wallet_transactions", {...})  # Use schema above

# 3. Create indexes
db.wallet_transactions.createIndex({ userId: 1 })
db.wallet_transactions.createIndex({ userId: 1, timestamp: -1 })

# 4. Verify creation
db.wallet_transactions.findOne()  # Should return empty {}
```

---

## 🔌 BACKEND 4: Node.js API Endpoints (If not using GraphQL directly)

### **Optional: REST API Endpoints** (If you prefer REST over GraphQL)

**File**: Your Express/Node.js backend (e.g., `routes/wallet.js`)

```javascript
// POST /api/wallet/deduct-tokens
app.post('/api/wallet/deduct-tokens', async (req, res) => {
  const { userId, amount, orderId, itemName } = req.body;
  
  try {
    // 1. Check balance
    const user = await UserDetail.findById(userId);
    if (user.shopTokens < amount) {
      return res.status(400).json({ 
        success: false, 
        error: 'Insufficient tokens' 
      });
    }
    
    // 2. Deduct tokens
    user.shopTokens -= amount;
    user.totalSpentTokens += amount;
    await user.save();
    
    // 3. Create transaction record
    const transaction = await WalletTransaction.create({
      userId,
      type: 'purchase',
      amount: -amount,
      description: `Purchased ${itemName}`,
      orderReference: orderId,
      paymentMethod: 'shopTokens',
      status: 'completed',
      timestamp: new Date(),
    });
    
    res.json({
      success: true,
      newBalance: user.shopTokens,
      transactionId: transaction._id
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/wallet/balance/:userId
app.get('/api/wallet/balance/:userId', async (req, res) => {
  try {
    const user = await UserDetail.findById(req.params.userId);
    res.json({
      shopTokens: user.shopTokens,
      gameTokens: user.gameTokens,
      walletBalance: user.walletBalance,
      totalSpent: user.totalSpentTokens
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/wallet/transactions/:userId
app.get('/api/wallet/transactions/:userId', async (req, res) => {
  try {
    const transactions = await WalletTransaction.find({ userId: req.params.userId })
      .sort({ timestamp: -1 })
      .limit(100);
    
    res.json({ transactions });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

---

## 📝 INTEGRATION CHECKLIST

### **Phase 1: Hygraph Setup (1-2 hours)**
- [ ] Add `shopTokens` field to UserDetail model
- [ ] Add `totalSpentTokens` field to UserDetail model  
- [ ] Create new WalletTransaction model with all fields
- [ ] Update Order model with `paymentMethod` and `tokensUsed`
- [ ] Add relationship between UserDetail and WalletTransaction
- [ ] Publish all changes

### **Phase 2: GraphQL Mutations (1-2 hours)**
- [ ] Add new queries to `graphql_queries.dart`
- [ ] Test queries in GraphQL Explorer in Hygraph
- [ ] Verify response formats match expectations
- [ ] Document any custom field names

### **Phase 3: Frontend Integration (2-3 hours)**
- [ ] Update `order_service_graphql.dart` to use new mutations
- [ ] Replace local `walletService.deductShopTokens()` with API call
- [ ] Add caching for offline support (optional)
- [ ] Test full payment flow with real data

### **Phase 4: MongoDB (1 hour)**
- [ ] Create wallet_transactions collection
- [ ] Create indexes
- [ ] Verify collections exist
- [ ] Test write permissions

### **Phase 5: Testing (2-3 hours)**
- [ ] Test adding tokens via Razorpay
- [ ] Test deducting tokens via purchase
- [ ] Verify transaction history appears
- [ ] Check token balance syncs
- [ ] Verify merged history display

---

## 🚀 IMMEDIATE NEXT STEPS

**To make this work RIGHT NOW (without backend)**:
```dart
// Current implementation uses SharedPreferences ONLY
// No backend calls needed for MVP testing
// Works perfectly for demos and internal testing
```

**To make this production-ready (NEEDS backend)**:
```dart
// Replace local calls with GraphQL mutations
// Before:
await walletService.deductShopTokens(amount);

// After:
final response = await graphQLService.mutate(
  mutation: deductShopTokensGraphQL,
  variables: {'userId': userId, 'amount': amount, 'orderId': orderId}
);
```

---

## 📊 SUMMARY TABLE

| Component | Status | Time | Backend |
|-----------|--------|------|---------|
| Hygraph Schema | ⚠️ TODO | 1-2h | REQUIRED |
| GraphQL Queries | ⚠️ TODO | 1-2h | REQUIRED |
| MongoDB Collections | ⚠️ TODO | 1h | OPTIONAL |
| REST API | ⚠️ TODO | 1-2h | OPTIONAL |
| Frontend Integration | ✅ READY | 2-3h | Calls existing code |

---

**Current MVP Status**: ✅ **100% working with local storage**  
**Production Status**: ⚠️ **Needs backend implementation**

Want me to help implement the frontend integration once backend is ready?
