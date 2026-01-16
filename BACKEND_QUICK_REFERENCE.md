# 🎯 BACKEND CHANGES - QUICK REFERENCE

## **3 BACKENDS NEEDING CHANGES**

### **1️⃣ HYGRAPH** (CMS - Content Model)
- Add `shopTokens: Float` to UserDetail
- Add `totalSpentTokens: Float` to UserDetail
- Create `WalletTransaction` model (8 fields)
- Update `Order` model (+2 fields)
- **Time**: 20 minutes
- **Complexity**: Easy (visual interface)

### **2️⃣ MONGODB** (Database)
- Create `wallet_transactions` collection with validator
- Create 5 indexes
- **Time**: 10 minutes
- **Complexity**: Medium (CLI commands)

### **3️⃣ GraphQL API** (if separate from Hygraph)
- Add 6 new queries/mutations to `graphql_queries.dart`
- Connect to Hygraph GraphQL endpoint
- **Time**: 1-2 hours
- **Complexity**: Medium (Dart code)

---

## **✅ WHAT'S ALREADY WORKING**

```
✅ Frontend UI complete
✅ Local token storage (SharedPreferences)
✅ Transaction history display
✅ Shop token payment option
✅ Token distribution logic
✅ Navigation redirect

⚠️ ONLY LOCAL - Will lose data on app reinstall
⚠️ NEEDS BACKEND for production
```

---

## **📋 HYGRAPH FIELDS TO ADD**

### **UserDetail Model - ADD**
```
shopTokens: Float (default 0)
totalSpentTokens: Float (default 0)
walletTransactions: [WalletTransaction] (relationship)
```

### **WalletTransaction Model - CREATE NEW**
```
userId: String (indexed)
type: Enum (add_money, purchase, refund, admin_adjustment)
amount: Float
description: String
orderReference: String (optional)
paymentMethod: String (optional)
timestamp: DateTime
status: Enum (pending, completed, failed, reversed)
metadata: JSON (optional)
```

### **Order Model - ADD**
```
paymentMethod: String
tokensUsed: Float
```

---

## **📝 GRAPHQL MUTATIONS TO ADD**

### **Mutation 1: Deduct Tokens**
```graphql
mutation DeductShopTokens($userId: ID!, $amount: Float!, $orderId: String!) {
  updateUserDetail(
    where: {id: $userId}
    data: {
      shopTokens: {decrement: $amount}
      totalSpentTokens: {increment: $amount}
    }
  ) { id shopTokens totalSpentTokens }
  
  createWalletTransaction(data: {
    userId: $userId
    type: purchase
    amount: -$amount
    orderReference: $orderId
    status: completed
    userDetail: {connect: {id: $userId}}
  }) { id }
}
```

### **Mutation 2: Add Tokens**
```graphql
mutation AddShopTokens($userId: ID!, $amount: Float!) {
  updateUserDetail(
    where: {id: $userId}
    data: {shopTokens: {increment: $amount}}
  ) { id shopTokens }
  
  createWalletTransaction(data: {
    userId: $userId
    type: add_money
    amount: $amount
    status: completed
    userDetail: {connect: {id: $userId}}
  }) { id }
}
```

### **Query 1: Get Wallet**
```graphql
query GetUserWallet($userId: ID!) {
  userDetail(where: {id: $userId}) {
    id
    walletBalance
    shopTokens
    totalSpentTokens
  }
}
```

### **Query 2: Get Transactions**
```graphql
query GetWalletTransactions($userId: String!, $first: Int = 50) {
  walletTransactions(
    where: {userId: $userId}
    first: $first
    orderBy: timestamp_DESC
  ) {
    id userId type amount description timestamp status
  }
}
```

---

## **🗄️ MONGODB COMMANDS**

```javascript
// Run these in MongoDB shell:

db.createCollection("wallet_transactions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "type", "amount", "timestamp"],
      properties: {
        userId: { bsonType: "string" },
        type: { enum: ["add_money", "purchase", "refund"] },
        amount: { bsonType: "double" },
        timestamp: { bsonType: "date" },
        status: { enum: ["pending", "completed", "failed"] }
      }
    }
  }
});

db.wallet_transactions.createIndex({ userId: 1 });
db.wallet_transactions.createIndex({ userId: 1, timestamp: -1 });
db.wallet_transactions.createIndex({ orderReference: 1 });
```

---

## **⚡ QUICK STEPS TO ENABLE**

### **For Hygraph** (Dashboard)
1. Go to Content Model
2. Find UserDetail → Add shopTokens field
3. Create WalletTransaction model
4. Update Order model
5. Click "Publish"

### **For MongoDB** (CLI)
1. Connect to MongoDB
2. Copy-paste commands above
3. Run `db.wallet_transactions.find()` to verify

### **For GraphQL** (Dart Code)
1. Add queries to `graphql_queries.dart`
2. Update `order_service_graphql.dart` to call new mutations
3. Replace local calls with API calls

---

## **📊 TIMELINE**

| Task | Time | Status |
|------|------|--------|
| Hygraph setup | 20m | ⚠️ TODO |
| MongoDB setup | 10m | ⚠️ TODO |
| GraphQL mutations | 1-2h | ⚠️ TODO |
| Frontend integration | 2-3h | ⚠️ TODO |
| **TOTAL** | **4-6h** | **2-3 hours/day** |

---

## **❓ FREQUENT QUESTIONS**

**Q: Is this required to use the wallet today?**  
A: No! Current implementation works 100% with local storage. This is for persistent data.

**Q: Can I test without backend?**  
A: Yes! Use current implementation. Data resets when app reinstalls.

**Q: How long to implement?**  
A: 4-6 hours total for experienced developer (1-2 hours per backend system)

**Q: Which is most important first?**  
A: Hygraph first (enables GraphQL), then MongoDB (stores data), then integrate with frontend.

**Q: Can I do partial implementation?**  
A: Yes! Do Hygraph + GraphQL first, MongoDB can be added later for analytics.

---

**For full details, see**: [BACKEND_CHANGES_REQUIRED.md](BACKEND_CHANGES_REQUIRED.md)
