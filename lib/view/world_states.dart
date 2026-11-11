import 'package:covid_trackor/view/country_list.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:covid_trackor/Services/states_services.dart';
import 'package:covid_trackor/Model/WorldStatesModel.dart';

class WorldStatesScreen extends StatefulWidget {
  const WorldStatesScreen({super.key});

  @override
  State<WorldStatesScreen> createState() => _WorldStatesScreenState();
}

class _WorldStatesScreenState extends State<WorldStatesScreen> {
  final StatesServices statesServices = StatesServices();
  late Future<WorldStatesModel> _future;

  final colorList = const <Color>[
    Color(0xff4285F4), // Total (blue)
    Color(0xff1aa260), // Recovered (green)
    Color(0xffde5246), // Deaths (red)
  ];

  @override
  void initState() {
    super.initState();
    _future = statesServices.fetchWorldStatesRecords();
  }

  void _reload() {
    setState(() {
      _future = statesServices.fetchWorldStatesRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1c1c1c),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<WorldStatesModel>(
            future: _future,
            builder: (context, snapshot) {
              // Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              // Error
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Failed to load data.\nCheck your internet connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _reload,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    PieChart(
                      dataMap: {
                        'Total': (data.cases ?? 0).toDouble(),
                        'Recovered': (data.recovered ?? 0).toDouble(),
                        'Deaths': (data.deaths ?? 0).toDouble(),
                      },
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 1,
                      ),
                      chartRadius: 100,
                      animationDuration: const Duration(milliseconds: 1200),
                      chartType: ChartType.ring,
                      ringStrokeWidth: 24,
                      colorList: colorList,
                      legendOptions: const LegendOptions(
                        legendPosition: LegendPosition.left,
                        legendTextStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff2a2a2a),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          ReusableRow(
                              title: 'Total', value: '${data.cases ?? 0}'),
                          ReusableRow(
                              title: 'Recovered',
                              value: '${data.recovered ?? 0}'),
                          ReusableRow(
                              title: 'Deaths', value: '${data.deaths ?? 0}'),
                          ReusableRow(
                              title: 'Active', value: '${data.active ?? 0}'),
                          ReusableRow(
                              title: 'Critical',
                              value: '${data.critical ?? 0}'),
                          ReusableRow(
                              title: 'Today Cases',
                              value: '${data.todayCases ?? 0}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Material(
                      color: const Color(0xff1aa260),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(

                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(context,
                             MaterialPageRoute(builder: (_) => const CountryListScreen()));
                        },
                        child: const SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Track Countries',
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ReusableRow extends StatelessWidget {
  final String title;
  final String value;

  const ReusableRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}