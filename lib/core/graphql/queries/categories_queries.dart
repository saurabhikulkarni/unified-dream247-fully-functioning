/// GraphQL queries for categories from Hygraph backend
library;

/// Query to fetch all categories
const String getAllCategoriesQuery = '''
  query GetCategories {
    categories(orderBy: name_ASC) {
      id
      name
      slug
      description
      icon {
        url
      }
      image {
        url
      }
      productsCount
      featured
      parentCategory {
        id
        name
      }
    }
  }
''';

/// Query to fetch category by slug
const String getCategoryBySlugQuery = '''
  query GetCategory(\$slug: String!) {
    category(where: { slug: \$slug }) {
      id
      name
      slug
      description
      icon {
        url
      }
      image {
        url
      }
      productsCount
      featured
      parentCategory {
        id
        name
        slug
      }
      subCategories {
        id
        name
        slug
        icon {
          url
        }
      }
    }
  }
''';

/// Query to fetch featured categories
const String getFeaturedCategoriesQuery = '''
  query GetFeaturedCategories {
    categories(
      where: { featured: true }
      orderBy: name_ASC
    ) {
      id
      name
      slug
      description
      icon {
        url
      }
      image {
        url
      }
      productsCount
    }
  }
''';
