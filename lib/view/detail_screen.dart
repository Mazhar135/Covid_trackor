import 'package:flutter/material.dart';

/// Screen that shows the full statistics of one selected country.
class DetailScreen extends StatelessWidget {
  // Data received from the country list screen
  final String name;
  final String image;
  final num totalCases;
  final num totalDeaths;
  final num totalRecovered;
  final num active;
  final num critical;
  final num todayRecovered;
  final num test;

  const DetailScreen({
    super.key,
    required this.name,
    required this.image,
    required this.totalCases,
    required this.totalDeaths,
    required this.totalRecovered,
    required this.active,
    required this.critical,
    required this.todayRecovered,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark grey screen background
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        // Country name in the top bar
        title: Text(name, style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Circular country flag
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade800,
                child: ClipOval(
                  child: Image.network(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover, // crops the flag to fill the circle
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.flag, color: Colors.grey, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Card holding all the statistics rows
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _row('Total Cases', totalCases),
                    _row('Total Deaths', totalDeaths),
                    _row('Total Recovered', totalRecovered),
                    _row('Active', active),
                    _row('Critical', critical),
                    _row('Today Recovered', todayRecovered),
                    _row('Tests', test),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One line of the card: label on the left, value on the right.
  Widget _row(String title, num value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}