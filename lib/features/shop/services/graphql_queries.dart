class GraphQLQueries {
  // Query to fetch all products
  static const String getAllProducts = '''
    query GetAllProducts {
      products(first: 1000) {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Query to fetch a single product by ID
  static const String getProductById = '''
    query GetProductById(\$id: ID!) {
      product(where: {id: \$id}) {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Query to fetch products by category
  static const String getProductsByCategory = '''
    query GetProductsByCategory(\$categoryName: String!) {
      products(first: 1000, where: {category: {categoryName: \$categoryName}}) {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Query to fetch all categories
  static const String getAllCategories = '''
    query GetAllCategories {
      categories(first: 1000) {
        id
        categoryName
        slug
      }
    }
  ''';

  // Query to fetch sizes for a product
  static const String getSizesByProduct = '''
    query GetSizesByProduct(\$productId: ID!) {
      sizes(first: 1000, where: {product: {id: \$productId}}) {
        id
        sizeName
        quantity
        product {
          id
        }
      }
    }
  ''';

  // Query to fetch cart items for a user
  static const String getCartByUser = '''
    query GetCartByUser(\$userId: ID!) {
      carts(first: 1000, where: {userDetail: {id: \$userId}}) {
        id
        quantity
        product {
          id
          productName
          slug
          description
          price
          image {
            url
          }
          category {
            id
            categoryName
          }
        }
        size {
          id
          sizeName
          quantity
        }
      }
    }
  ''';

  // Query to fetch user details
  static const String getUserById = '''
    query GetUserById(\$id: ID!) {
      userDetail(where: {id: \$id}) {
        id
        firstName
        lastName
        username
        mobileNumber
        walletBalance
      }
    }
  ''';

  // Query to fetch user by mobile number (for login)
  static const String getUserByMobileNumber = '''
    query GetUserByMobileNumber(\$mobileNumber: String!) {
      userDetails(where: {mobileNumber: \$mobileNumber}) {
        id
        firstName
        lastName
        username
        mobileNumber
        walletBalance
      }
    }
  ''';
  
  // Query to fetch user by username (for backward compatibility)
  static const String getUserByUsername = '''
    query GetUserByUsername(\$username: String!) {
      userDetails(where: {username: \$username}) {
        id
        firstName
        lastName
        username
        mobileNumber
        walletBalance
      }
    }
  ''';

  // Search products by name
  static const String searchProducts = '''
    query SearchProducts(\$searchTerm: String!) {
      products(
        first: 1000,
        where: {
          OR: [
            {productName_contains: \$searchTerm}
            {description_contains: \$searchTerm}
            {category: {categoryName_contains: \$searchTerm}}
          ]
        }
      ) {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Mutations

  // Create a new cart item (with size)
  static const String createCartItemWithSize = '''
    mutation CreateCartItemWithSize(\$quantity: String!, \$userId: ID!, \$productId: ID!, \$sizeId: ID!) {
      createCart(
        data: {
          quantity: \$quantity
          userDetail: {connect: {id: \$userId}}
          product: {connect: {id: \$productId}}
          size: {connect: {id: \$sizeId}}
        }
      ) {
        id
        quantity
      }
    }
  ''';

  // Create a new cart item (without size)
  static const String createCartItemWithoutSize = '''
    mutation CreateCartItemWithoutSize(\$quantity: String!, \$userId: ID!, \$productId: ID!) {
      createCart(
        data: {
          quantity: \$quantity
          userDetail: {connect: {id: \$userId}}
          product: {connect: {id: \$productId}}
        }
      ) {
        id
        quantity
      }
    }
  ''';

  // Update cart item quantity
  static const String updateCartItem = '''
    mutation UpdateCartItem(\$cartId: ID!, \$quantity: String!) {
      updateCart(
        where: {id: \$cartId}
        data: {quantity: \$quantity}
      ) {
        id
        quantity
      }
    }
  ''';

  // Delete cart item
  static const String deleteCartItem = '''
    mutation DeleteCartItem(\$cartId: ID!) {
      deleteCart(where: {id: \$cartId}) {
        id
      }
    }
  ''';

  // Create new user
  static const String createUser = '''
    mutation CreateUser(\$firstName: String!, \$lastName: String!, \$username: String!, \$mobileNumber: String!) {
      createUserDetail(
        data: {
          firstName: \$firstName
          lastName: \$lastName
          username: \$username
          mobileNumber: \$mobileNumber
        }
      ) {
        id
        firstName
        lastName
        username
        mobileNumber
      }
    }
  ''';

  // Publish user (required for Hygraph)
  static const String publishUser = '''
    mutation PublishUser(\$id: ID!) {
      publishUserDetail(where: {id: \$id}) {
        id
      }
    }
  ''';

  // Publish cart item
  static const String publishCart = '''
    mutation PublishCart(\$id: ID!) {
      publishCart(where: {id: \$id}) {
        id
      }
    }
  ''';

  // ============ Wallet Queries & Mutations ============
  
  // Get user wallet balance
  static const String getUserWallet = '''
    query GetUserWallet(\$userId: ID!) {
      userDetail(where: {id: \$userId}) {
        id
        walletBalance
      }
    }
  ''';

  // Update user wallet balance
  static const String updateWalletBalance = '''
    mutation UpdateWalletBalance(\$userId: ID!, \$walletBalance: Int!) {
      updateUserDetail(
        where: {id: \$userId}
        data: {walletBalance: \$walletBalance}
      ) {
        id
        walletBalance
      }
    }
  ''';

  // ============ Address Queries & Mutations ============
  
  // Get all addresses for a user
  static const String getAddressesByUser = '''
    query GetAddressesByUser(\$userId: ID!) {
      addresses(first: 1000, where: {userDetail: {id: \$userId}}) {
        id
        fullName
        phoneNumber
        pincode
        addressLine1
        addressLine2
        city
        state
        country
        isDefault
        createdAt
        updatedAt
      }
    }
  ''';

  // Get a single address by ID
  static const String getAddressById = '''
    query GetAddressById(\$id: ID!) {
      address(where: {id: \$id}) {
        id
        fullName
        phoneNumber
        pincode
        addressLine1
        addressLine2
        city
        state
        country
        isDefault
        createdAt
        updatedAt
        userDetail {
          id
        }
      }
    }
  ''';

  // Create a new address
  static const String createAddress = '''
    mutation CreateAddress(
      \$userId: ID!
      \$fullName: String!
      \$phoneNumber: Int!
      \$pincode: String!
      \$addressLine1: String!
      \$addressLine2: String
      \$city: String!
      \$state: String!
      \$country: String!
      \$isDefault: Boolean!
    ) {
      createAddress(
        data: {
          userDetail: {connect: {id: \$userId}}
          fullName: \$fullName
          phoneNumber: \$phoneNumber
          pincode: \$pincode
          addressLine1: \$addressLine1
          addressLine2: \$addressLine2
          city: \$city
          state: \$state
          country: \$country
          isDefault: \$isDefault
        }
      ) {
        id
        fullName
        phoneNumber
        pincode
        addressLine1
        addressLine2
        city
        state
        country
        isDefault
      }
    }
  ''';

  // Update an address
  static const String updateAddress = '''
    mutation UpdateAddress(
      \$id: ID!
      \$fullName: String!
      \$phoneNumber: Int!
      \$pincode: String!
      \$addressLine1: String!
      \$addressLine2: String
      \$city: String!
      \$state: String!
      \$country: String!
      \$isDefault: Boolean!
    ) {
      updateAddress(
        where: {id: \$id}
        data: {
          fullName: \$fullName
          phoneNumber: \$phoneNumber
          pincode: \$pincode
          addressLine1: \$addressLine1
          addressLine2: \$addressLine2
          city: \$city
          state: \$state
          country: \$country
          isDefault: \$isDefault
        }
      ) {
        id
        fullName
        phoneNumber
        pincode
        addressLine1
        addressLine2
        city
        state
        country
        isDefault
      }
    }
  ''';

  // Delete an address
  static const String deleteAddress = '''
    mutation DeleteAddress(\$id: ID!) {
      deleteAddress(where: {id: \$id}) {
        id
      }
    }
  ''';

  // Publish address (required for Hygraph)
  static const String publishAddress = '''
    mutation PublishAddress(\$id: ID!) {
      publishAddress(where: {id: \$id}) {
        id
      }
    }
  ''';

  // Update all addresses to set isDefault to false (before setting a new default)
  static const String unsetAllDefaultAddresses = '''
    mutation UnsetAllDefaultAddresses(\$userId: ID!) {
      updateManyAddresses(
        where: {userDetail: {id: \$userId}, isDefault: true}
        data: {isDefault: false}
      ) {
        count
      }
    }
  ''';

  // Increment wallet balance (add money)
  static const String addWalletBalance = '''
    mutation AddWalletBalance(\$userId: ID!, \$amount: Float!) {
      updateUserDetail(
        where: {id: \$userId}
        data: {walletBalance: {increment: \$amount}}
      ) {
        id
        walletBalance
      }
    }
  ''';

  // Decrement wallet balance (deduct money)
  static const String deductWalletBalance = '''
    mutation DeductWalletBalance(\$userId: ID!, \$amount: Float!) {
      updateUserDetail(
        where: {id: \$userId}
        data: {walletBalance: {decrement: \$amount}}
      ) {
        id
        walletBalance
      }
    }
  ''';

  // ============ Wishlist Queries & Mutations ============
  
  // Get user wishlist from separate Wishlist collection
  static const String getUserWishlist = '''
    query GetUserWishlist(\$userId: ID!) {
      wishlists(first: 1000, where: {userDetail: {id: \$userId}}) {
        id
        product {
          id
          productName
          slug
          description
          price
          image {
            url
          }
          category {
            id
            categoryName
          }
        }
      }
    }
  ''';

  // Add product to wishlist - creates new Wishlist record
  static const String addToWishlist = '''
    mutation AddToWishlistWithoutSize(\$userId: ID!, \$productId: ID!) {
      createWishlist(
        data: {
          userDetail: {connect: {id: \$userId}}
          product: {connect: {id: \$productId}}
        }
      ) {
        id
        product {
          id
          productName
          price
        }
      }
    }
  ''';

  // Remove product from wishlist - deletes Wishlist record
  static const String removeFromWishlist = '''
    mutation RemoveFromWishlist(\$wishlistId: ID!) {
      deleteWishlist(where: {id: \$wishlistId}) {
        id
      }
    }
  ''';

  // Get full user profile with wallet
  static const String getUserProfile = '''
    query GetUserProfile(\$userId: ID!) {
      userDetail(where: {id: \$userId}) {
        id
        firstName
        lastName
        username
        mobileNumber
        walletBalance
      }
    }
  ''';

  // ============ Order Queries & Mutations ============
  
  // Get all orders for a user
  static const String getUserOrders = '''
    query GetUserOrders(\$userId: ID!) {
      orders(first: 1000, where: {userDetail: {id: \$userId}}, orderBy: createdAt_DESC) {
        id
        orderNumber
        totalAmount
        orderStatus
        createdAt
        updatedAt
        trackingNumber
        courierName
        shiprocketOrderId
        address {
          id
          fullName
          phoneNumber
          pincode
          addressLine1
          addressLine2
          city
          state
          country
        }
      }
    }
  ''';

  // Get order by ID
  static const String getOrderById = '''
    query GetOrderById(\$id: ID!) {
      order(where: {id: \$id}) {
        id
        orderNumber
        totalAmount
        orderStatus
        createdAt
        updatedAt
        trackingNumber
        courierName
        shiprocketOrderId
        address {
          id
          fullName
          phoneNumber
          pincode
          addressLine1
          addressLine2
          city
          state
          country
        }
      }
    }
  ''';

  // Get order items by order ID
  static const String getOrderItemsByOrderId = '''
    query GetOrderItemsByOrderId(\$orderId: ID!) {
      orderItems(where: {order: {id: \$orderId}}) {
        id
        quantity
        pricePerUnit
        totalPrice
        product {
          id
          productName
          price
          image {
            url
          }
        }
      }
    }
  ''';

  // OPTIMIZED: Create order WITH items in a single call (batch operation)
  static const String createOrderBatch = '''
    mutation CreateOrderBatch(
      \$orderNumber: String!,
      \$userId: ID!,
      \$totalAmount: Float!,
      \$orderStatus: OrderStatus!,
      \$addressId: ID
    ) {
      createOrder(
        data: {
          orderNumber: \$orderNumber
          userDetail: {connect: {id: \$userId}}
          totalAmount: \$totalAmount
          orderStatus: \$orderStatus
          address: \$addressId != null ? {connect: {id: \$addressId}} : null
        }
      ) {
        id
        orderNumber
        totalAmount
        orderStatus
        createdAt
      }
    }
  ''';

  // Create order without shipping address (legacy - keeping for backwards compatibility)
  static const String createOrderWithoutAddress = '''
    mutation CreateOrderWithoutAddress(
      \$userId: ID!,
      \$orderNumber: String!,
      \$totalAmount: Float!,
      \$orderStatus: OrderStatus!
    ) {
      createOrder(
        data: {
          orderNumber: \$orderNumber
          userDetail: {connect: {id: \$userId}}
          totalAmount: \$totalAmount
          orderStatus: \$orderStatus
        }
      ) {
        id
        orderNumber
        totalAmount
        orderStatus
        createdAt
      }
    }
  ''';

  // Create order with shipping address
  static const String createOrderWithAddress = '''
    mutation CreateOrderWithAddress(
      \$userId: ID!,
      \$orderNumber: String!,
      \$totalAmount: Float!,
      \$orderStatus: OrderStatus!,
      \$addressId: ID!
    ) {
      createOrder(
        data: {
          orderNumber: \$orderNumber
          userDetail: {connect: {id: \$userId}}
          totalAmount: \$totalAmount
          orderStatus: \$orderStatus
          address: {connect: {id: \$addressId}}
        }
      ) {
        id
        orderNumber
        totalAmount
        orderStatus
        createdAt
      }
    }
  ''';

  // Create order item with size
  static const String createOrderItemWithSize = '''
    mutation CreateOrderItemWithSize(
      \$orderId: ID!,
      \$productId: ID!,
      \$sizeId: ID!,
      \$quantity: Int!,
      \$pricePerUnit: Float!,
      \$totalPrice: Float!
    ) {
      createOrderItem(
        data: {
          order: {connect: {id: \$orderId}}
          product: {connect: {id: \$productId}}
          sizes: {connect: {id: \$sizeId}}
          quantity: \$quantity
          pricePerUnit: \$pricePerUnit
          totalPrice: \$totalPrice
        }
      ) {
        id
        quantity
        pricePerUnit
        totalPrice
      }
    }
  ''';

  // Create order item without size
  static const String createOrderItemWithoutSize = '''
    mutation CreateOrderItemWithoutSize(
      \$orderId: ID!,
      \$productId: ID!,
      \$quantity: Int!,
      \$pricePerUnit: Float!,
      \$totalPrice: Float!
    ) {
      createOrderItem(
        data: {
          order: {connect: {id: \$orderId}}
          product: {connect: {id: \$productId}}
          quantity: \$quantity
          pricePerUnit: \$pricePerUnit
          totalPrice: \$totalPrice
        }
      ) {
        id
        quantity
        pricePerUnit
        totalPrice
      }
    }
  ''';

  // Update order status
  static const String updateOrderStatus = '''
    mutation UpdateOrderStatus(\$id: ID!, \$orderStatus: OrderStatus!) {
      updateOrder(
        where: {id: \$id}
        data: {orderStatus: \$orderStatus}
      ) {
        id
        orderStatus
        updatedAt
      }
    }
  ''';

  // Update order tracking info
  static const String updateOrderTracking = '''
    mutation UpdateOrderTracking(
      \$id: ID!,
      \$trackingNumber: String,
      \$courierName: String,
      \$shiprocketOrderId: String
    ) {
      updateOrder(
        where: {id: \$id}
        data: {
          trackingNumber: \$trackingNumber
          courierName: \$courierName
          shiprocketOrderId: \$shiprocketOrderId
        }
      ) {
        id
        trackingNumber
        courierName
        shiprocketOrderId
        updatedAt
      }
    }
  ''';

  // Cancel order
  static const String cancelOrder = '''
    mutation CancelOrder(\$id: ID!) {
      updateOrder(
        where: {id: \$id}
        data: {orderStatus: CANCELLED}
      ) {
        id
        orderStatus
        updatedAt
      }
    }
  ''';

  // Publish order
  static const String publishOrder = '''
    mutation PublishOrder(\$id: ID!) {
      publishOrder(where: {id: \$id}) {
        id
      }
    }
  ''';

  // OPTIMIZED: Publish multiple order items at once (batch publish)
  static const String publishManyOrderItems = '''
    mutation PublishManyOrderItems(\$ids: [ID!]!) {
      publishManyOrderItems(where: {id_in: \$ids}) {
        count
      }
    }
  ''';

  // Publish order item
  static const String publishOrderItem = '''
    mutation PublishOrderItem(\$id: ID!) {
      publishOrderItem(where: {id: \$id}) {
        id
      }
    }
  ''';

  // ============ Payment Queries & Mutations ============
  
  // Get all payments for a user
  static const String getUserPayments = '''
    query GetUserPayments(\$userId: ID!, \$orderBy: PaymentOrderByInput) {
      payments(where: {userDetail: {id: \$userId}}, orderBy: \$orderBy) {
        id
        razorpayOrderId
        razorpayPaymentId
        amount
        currency
        status
        method
        orderId
        createdAt
        updatedAt
        order {
          id
          orderNumber
        }
      }
    }
  ''';

  // Get payment by ID
  static const String getPaymentById = '''
    query GetPaymentById(\$id: ID!) {
      payment(where: {id: \$id}) {
        id
        razorpayOrderId
        razorpayPaymentId
        amount
        currency
        status
        method
        orderId
        createdAt
        updatedAt
        order {
          id
          orderNumber
        }
      }
    }
  ''';

  // Get payment by Razorpay order ID
  static const String getPaymentByRazorpayOrderId = '''
    query GetPaymentByRazorpayOrderId(\$razorpayOrderId: String!) {
      payment(where: {razorpayOrderId: \$razorpayOrderId}) {
        id
        razorpayOrderId
        razorpayPaymentId
        amount
        currency
        status
        method
        orderId
        createdAt
        updatedAt
      }
    }
  ''';

  // Create payment record
  static const String createPayment = '''
    mutation CreatePayment(
      \$userId: ID!,
      \$razorpayOrderId: String!,
      \$razorpayPaymentId: String,
      \$amount: Float!,
      \$currency: String!,
      \$status: PaymentStatus!,
      \$method: String,
      \$orderId: ID
    ) {
      createPayment(
        data: {
          userDetail: {connect: {id: \$userId}}
          razorpayOrderId: \$razorpayOrderId
          razorpayPaymentId: \$razorpayPaymentId
          amount: \$amount
          currency: \$currency
          status: \$status
          method: \$method
          order: {connect: {id: \$orderId}}
        }
      ) {
        id
        razorpayOrderId
        razorpayPaymentId
        amount
        currency
        status
        method
        createdAt
      }
    }
  ''';

  // Update payment status
  static const String updatePaymentStatus = '''
    mutation UpdatePaymentStatus(\$id: ID!, \$status: PaymentStatus!) {
      updatePayment(
        where: {id: \$id}
        data: {status: \$status}
      ) {
        id
        status
        updatedAt
      }
    }
  ''';

  // Update payment with Razorpay payment ID
  static const String updatePaymentWithRazorpayId = '''
    mutation UpdatePaymentWithRazorpayId(
      \$id: ID!,
      \$razorpayPaymentId: String!,
      \$status: PaymentStatus!
    ) {
      updatePayment(
        where: {id: \$id}
        data: {
          razorpayPaymentId: \$razorpayPaymentId
          status: \$status
        }
      ) {
        id
        razorpayPaymentId
        status
        updatedAt
      }
    }
  ''';

  // Publish payment
  static const String publishPayment = '''
    mutation PublishPayment(\$id: ID!) {
      publishPayment(where: {id: \$id}) {
        id
      }
    }
  ''';

  // ============ Stock/Size Update Queries ============
  
  // Update size quantity (stock)
  static const String updateSizeQuantity = '''
    mutation UpdateSizeQuantity(\$id: ID!, \$quantity: Int!) {
      updateSize(
        where: {id: \$id}
        data: {quantity: \$quantity}
      ) {
        id
        sizeName
        quantity
        updatedAt
      }
    }
  ''';

  // Publish size after update
  static const String publishSize = '''
    mutation PublishSize(\$id: ID!) {
      publishSize(where: {id: \$id}) {
        id
      }
    }
  ''';

  // Get size by ID
  static const String getSizeById = '''
    query GetSizeById(\$id: ID!) {
      size(where: {id: \$id}) {
        id
        sizeName
        quantity
        product {
          id
          productName
        }
      }
    }
  ''';
}
