import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Shimmer package for the loading effect
// Adjust this path to where your service file lives
import 'package:covid_trackor/Services/states_services.dart';

/// Screen that shows a searchable list of countries with their flags.
class CountryListScreen extends StatefulWidget {
  const CountryListScreen({super.key});

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  // Controls the text typed in the search box
  final TextEditingController searchController = TextEditingController();

  // Service class that talks to the API
  final StatesServices statesServices = StatesServices();

  // Holds the API request. FutureBuilder listens to it and rebuilds the UI.
  // "late" means it is assigned later, in initState()
  late Future<List<dynamic>> _countriesFuture;

  // Current search text, used to filter the list
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Start fetching the country list once, when the screen opens
    _countriesFuture = statesServices.CountryListApi();
  }

  @override
  void dispose() {
    // Free the controller's memory when the screen is closed
    searchController.dispose();
    super.dispose();
  }

  /// Called by the Retry button: starts a fresh API request.
  /// setState tells Flutter to rebuild so FutureBuilder uses the new Future.
  void _retry() {
    setState(() {
      _countriesFuture = statesServices.CountryListApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Black screen background
      backgroundColor: Colors.black,

      // Top bar, also black, with white back arrow and title
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Select Country',
            style: TextStyle(color: Colors.white)),
      ),

      // SafeArea keeps content away from notches and system bars
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Search box ----------
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: searchController,
                // Every time the user types, save the text and rebuild
                // so the list below gets filtered
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search with country name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ---------- Country list ----------
            // Expanded gives the list all remaining height under the search box
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _countriesFuture,
                builder: (context, snapshot) {
                  // 1) Still loading: show shimmer placeholder rows
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      itemCount: 8, // number of fake rows to show
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade700, // normal grey
                          highlightColor:
                          Colors.grey.shade100, // moving light shine
                          child: ListTile(
                            // Square box where the flag will appear
                            leading: Container(
                              height: 50,
                              width: 50,
                              color: Colors.white,
                            ),
                            // Fake line where the country name will appear
                            title: Container(
                              height: 10,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            // Fake line where the cases text will appear
                            subtitle: Container(
                              height: 10,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // 2) Request failed: show a message and a Retry button
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Failed to load countries',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _retry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // 3) Data loaded: keep only countries whose name
                  //    contains the search text (case-insensitive)
                  final countries = snapshot.data!.where((item) {
                    final name = (item['country'] ?? '').toString();
                    return name.toLowerCase().contains(_query.toLowerCase());
                  }).toList();

                  // Nothing matched the search
                  if (countries.isEmpty) {
                    return const Center(
                      child: Text('No countries found',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // Build the scrollable list, one row per country
                  return ListView.builder(
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final item = countries[index];

                      // Flag URL is nested inside "countryInfo" in the JSON
                      final flag = item['countryInfo']?['flag'] ?? '';

                      return ListTile(
                        // Country flag image on the left
                        leading: Image.network(
                          flag,
                          width: 40,
                          // If the flag fails to load, show a flag icon instead
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.flag, color: Colors.grey),
                        ),
                        // Country name
                        title: Text(item['country'] ?? '',
                            style: const TextStyle(color: Colors.white)),
                        // Total cases shown under the name
                        subtitle: Text('Cases: ${item['cases'] ?? 0}',
                            style: const TextStyle(color: Colors.grey)),
                        // On tap, close this screen and send the selected
                        // country back to the previous screen
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}