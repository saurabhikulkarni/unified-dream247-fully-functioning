import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/search_service.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/route/screen_export.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _performSearch(String query) async {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    // Debounce: wait 500ms before searching
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await searchService.searchProducts(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
            _errorMessage = null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
            _errorMessage = 'Search failed. Please try again.';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = searchService.getSearchHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isEmpty && _searchController.text.isEmpty
                    ? ListView(
                        children: [
                          if (recentSearches.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Recent Searches",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        searchService.clearSearchHistory();
                                      });
                                    },
                                    child: const Text("Clear All"),
                                  ),
                                ],
                              ),
                            ),
                          ...recentSearches.map((search) => ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(search),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      searchService.removeFromSearchHistory(search);
                                    });
                                  },
                                ),
                                onTap: () {
                                  _searchController.text = search;
                                  _performSearch(search);
                                },
                              )),
                        ],
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                                const SizedBox(height: defaultPadding),
                                Text(
                                  _errorMessage!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                                const SizedBox(height: defaultPadding),
                                Text(
                                  'No products found for "${_searchController.text}"',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final product = _searchResults[index];
                              return ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: NetworkImageWithLoader(
                                    product.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(product.title),
                                subtitle: Text("${product.price.toInt()} tokens"),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(product: product),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

