/// GraphQL mutations for cart operations

/// Mutation to add item to cart
const String addToCartMutation = '''
  mutation AddToCart(\$userId: ID!, \$productId: ID!, \$quantity: Int!) {
    createCartItem(
      data: {
        user: { connect: { id: \$userId } }
        product: { connect: { id: \$productId } }
        quantity: \$quantity
      }
    ) {
      id
      product {
        id
        name
        price
        discountPrice
        images {
          url
        }
      }
      quantity
      createdAt
    }
  }
''';

/// Mutation to update cart item quantity
const String updateCartItemMutation = '''
  mutation UpdateCartItem(\$id: ID!, \$quantity: Int!) {
    updateCartItem(
      where: { id: \$id }
      data: { quantity: \$quantity }
    ) {
      id
      quantity
      updatedAt
    }
  }
''';

/// Mutation to remove item from cart
const String removeFromCartMutation = '''
  mutation RemoveFromCart(\$id: ID!) {
    deleteCartItem(where: { id: \$id }) {
      id
    }
  }
''';

/// Mutation to clear user's cart
const String clearCartMutation = '''
  mutation ClearCart(\$userId: ID!) {
    deleteManyCartItems(where: { user: { id: \$userId } }) {
      count
    }
  }
''';
