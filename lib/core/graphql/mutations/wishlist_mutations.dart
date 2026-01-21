/// GraphQL mutations for wishlist operations
library;

/// Mutation to add product to wishlist
const String addToWishlistMutation = '''
  mutation AddToWishlist(\$userId: ID!, \$productId: ID!) {
    createWishlistItem(
      data: {
        user: { connect: { id: \$userId } }
        product: { connect: { id: \$productId } }
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
      createdAt
    }
  }
''';

/// Mutation to remove product from wishlist
const String removeFromWishlistMutation = '''
  mutation RemoveFromWishlist(\$id: ID!) {
    deleteWishlistItem(where: { id: \$id }) {
      id
    }
  }
''';

/// Mutation to clear user's wishlist
const String clearWishlistMutation = '''
  mutation ClearWishlist(\$userId: ID!) {
    deleteManyWishlistItems(where: { user: { id: \$userId } }) {
      count
    }
  }
''';
