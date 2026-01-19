class GraphQLConfig {
  // Hygraph Content API endpoint (Production)
  // CDN endpoint for published content
  static const String hygraphCdnEndpoint =
      'https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master';
  
  // Content API endpoint with auth (for mutations and draft content)
  static const String hygraphContentApiEndpoint =
      'https://ap-south-1.hygraph.com/v2/cmj85rtgv038n07uo8egj5fkb/master';
  
  // Permanent Auth Token for Content API (read-only)
  // This token allows reading published AND draft content
  static const String hygraphAuthToken =
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImdjbXMtbWFpbi1wcm9kdWN0aW9uIn0.eyJ2ZXJzaW9uIjozLCJpYXQiOjE3NDg0MTU0OTQsImF1ZCI6WyJodHRwczovL2FwaS1hcC1zb3V0aC0xLmh5Z3JhcGguY29tL3YyL2Ntajg1cnRndjAzOG4wN3VvOGVnajVma2IvbWFzdGVyIiwibWFuYWdlbWVudC1uZXh0LmdyYXBoY21zLmNvbSJdLCJpc3MiOiJodHRwczovL21hbmFnZW1lbnQtYXAtc291dGgtMS5oeWdyYXBoLmNvbS8iLCJzdWIiOiI2ODE3YzE3ZS0xZjFlLTQ2YWQtYjgzOS00NDU0Njc0YjFlMWUiLCJqdGkiOiJjbTllbXQ5dTcwNjc0MDdsNmEyeTN3cTc4In0.R2mN-FQoUqLrQZPn0tMUjXe7xpGFkQeMBIUkqJzNVD9RIDilPMb4Nc_3zJQ7PDbzwrLNP4zt0zN2wDfSk_z8KPYGcfP8NMT1jdwSVZmN-jBMpjNBMexmNAF8bBBYD6iKI0kIlEKvKH_mVxWoqf5LQ5eeHMJ1ZCyIOvGrC5VX_xRhLyH8mfr5G2KNhMjvOOOkWXlDHwVWqRwdqkGHYDmCfJW7kPb1kcXXZjRKGRQ4hpHqFkRQGb-q1M3rQrjg5GZ0-4uHhLNlNWBvE-kbMpHQG5vCXBq7rQeKEkXzLN0TZmHVXOB5_QG5rqmJhR4vZ1BHnQGJvkzJhRmNKQzWvXpH3DQKBF1C0pKH2z3_1xWqvRrJhNqMzKHpBmFxV5TQzWvXpH3D';
  
  // Default endpoint to use (CDN for faster reads)
  static const String hygraphEndpoint = hygraphCdnEndpoint;
  
  // Whether to use auth token (set to true if products not showing)
  static const bool useAuthToken = true;
}
