/// GraphQL queries for products from Hygraph backend
library;

/// Query to fetch all products with pagination
const String getAllProductsQuery = '''
  query GetProducts(\$first: Int!, \$skip: Int!) {
    products(first: \$first, skip: \$skip, orderBy: createdAt_DESC) {
      id
      name
      description
      price
      discountPrice
      category {
        id
        name
        slug
      }
      images {
        url
      }
      stock
      rating
      reviewCount
      tags
      featured
      createdAt
    }
  }
''';

/// Query to fetch single product by ID
const String getProductByIdQuery = '''
  query GetProduct(\$id: ID!) {
    product(where: { id: \$id }) {
      id
      name
      description
      longDescription {
        html
      }
      price
      discountPrice
      category {
        id
        name
        slug
      }
      images {
        url
      }
      stock
      rating
      reviewCount
      tags
      featured
      specifications {
        key
        value
      }
      relatedProducts {
        id
        name
        price
        discountPrice
        images {
          url
        }
      }
      createdAt
      updatedAt
    }
  }
''';

/// Query to fetch products by category
const String getProductsByCategoryQuery = '''
  query GetProductsByCategory(\$categorySlug: String!, \$first: Int!, \$skip: Int!) {
    products(
      where: { category: { slug: \$categorySlug } }
      first: \$first
      skip: \$skip
      orderBy: createdAt_DESC
    ) {
      id
      name
      description
      price
      discountPrice
      images {
        url
      }
      stock
      rating
      reviewCount
      tags
      featured
    }
  }
''';

/// Query to search products by name or tags
const String searchProductsQuery = '''
  query SearchProducts(\$searchTerm: String!, \$first: Int!) {
    products(
      where: {
        OR: [
          { name_contains: \$searchTerm }
          { description_contains: \$searchTerm }
          { tags_contains_some: [\$searchTerm] }
        ]
      }
      first: \$first
      orderBy: createdAt_DESC
    ) {
      id
      name
      description
      price
      discountPrice
      images {
        url
      }
      stock
      rating
      reviewCount
      tags
      featured
    }
  }
''';

/// Query to fetch featured products
const String getFeaturedProductsQuery = '''
  query GetFeaturedProducts(\$first: Int!) {
    products(
      where: { featured: true }
      first: \$first
      orderBy: rating_DESC
    ) {
      id
      name
      description
      price
      discountPrice
      images {
        url
      }
      stock
      rating
      reviewCount
      tags
    }
  }
''';

/// Query to fetch products by price range
const String getProductsByPriceRangeQuery = '''
  query GetProductsByPriceRange(\$minPrice: Float!, \$maxPrice: Float!, \$first: Int!) {
    products(
      where: {
        AND: [
          { price_gte: \$minPrice }
          { price_lte: \$maxPrice }
        ]
      }
      first: \$first
      orderBy: price_ASC
    ) {
      id
      name
      description
      price
      discountPrice
      images {
        url
      }
      stock
      rating
      reviewCount
    }
  }
''';
