class GraphQLConfig {
  // Hygraph Content API endpoint (Production)
  // CDN endpoint for published content (READ-ONLY)
  static const String hygraphCdnEndpoint =
      'https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master';
  
  // Content API endpoint with auth (for mutations and draft content)
  // NOTE: Must use 'api-ap-south-1' not just 'ap-south-1'
  static const String hygraphContentApiEndpoint =
      'https://api-ap-south-1.hygraph.com/v2/cmj85rtgv038n07uo8egj5fkb/master';
  
  // Permanent Auth Token for Content API (with WRITE permissions)
  // This token allows creating, updating, and publishing content
  static const String hygraphAuthToken =
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImdjbXMtbWFpbi1wcm9kdWN0aW9uIn0.eyJ2ZXJzaW9uIjozLCJpYXQiOjE3Njg3NTgzMDYsImF1ZCI6WyJodHRwczovL2FwaS1hcC1zb3V0aC0xLmh5Z3JhcGguY29tL3YyL2Ntajg1cnRndjAzOG4wN3VvOGVnajVma2IvbWFzdGVyIiwibWFuYWdlbWVudC1uZXh0LmdyYXBoY21zLmNvbSJdLCJpc3MiOiJodHRwczovL21hbmFnZW1lbnQtYXAtc291dGgtMS5oeWdyYXBoLmNvbS8iLCJzdWIiOiJmZTQyNTVjZS04YjRhLTRmM2ItOWE1ZC0zOWU0MGIwZTJhZDYiLCJqdGkiOiJjbWtrMTB6enAwdWYyMDdvMmQxcWIzdm5iIn0.mxEdIQAz-EbWd_4noK5GqKRIFd3hMyyoOLFJ5K66BO4Dm1Z9ljwfyCNY-TyXOsu1IDD2Ld61qGQMM6W6XhcLZigIkZyhMfyzY2RcxuM4N8-mFWMngGdqOfPVVVOis5wqU-M-K3o_J3UGWmwpl3HXBpj_RShQnlmPNrH-tG51c4swVJK--0mqlPEZ43NzBFt2KtCPVqbxijXU0-ciBVYrBfiuyjmCD6WhhxQ3LAIBiGq1lgDaXtNYTON02NbZO6ABO8vGqvA1BZ0f6Xn9Ufvk95mYoP9r8ZQ3glw8WT9n8exVuezXuMky2ylvNJivNklAIDrI2z86qgntCO8XoFUrtTecueB4k4tKTJnHp5J0Z2r7Qk1DTIVZICbgbhE7rEw2Lm-YzaVkOmNfZdUS9wCtFCTI-RnoU6IqMSCH6M6rGlH0lTWsk7MpsdBWdwyOgRxdyosUKT0Hd3maf3M9_ww2r7bes_GlCnahAd4LbDEL7HGCqkdIO5-m2u8vu8wvHYrB4EKd6Xld_L9UykF84UvSZrJLTQGrxUrepaDL1kvED6I8Gm49Ao3BzzRgybyk7gWmnOLNeWWLwjxTXqhWqZOSWUMVg7yjA3EUKtgWgaqOm_zuD2N0hkhZA95SnRoIA0X1j-pZEfypAJBqAg8fSEU9EeJ_Z_GfsEunud4G3N8bOQ8';
  
  // Default endpoint to use (CDN for faster reads)
  static const String hygraphEndpoint = hygraphCdnEndpoint;
  
  // Whether to use auth token
  // Set to TRUE for mutations (create/update/delete) - REQUIRED for signup
  // The Content API with auth token is needed for write operations
  static const bool useAuthToken = true;
}
