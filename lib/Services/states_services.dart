import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:covid_trackor/Model/WorldStatesModel.dart';


import '../Utilities/app_urls.dart';

class StatesServices {
  Future<WorldStatesModel> fetchWorldStatesRecords() async {
    final response = await http.get(Uri.parse(AppUrl.worldStatesApi));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WorldStatesModel.fromJson(data);
    } else {
      throw Exception('Error: failed to load data');
    }
  }

  Future<List<dynamic>> CountryListApi() async {
    var data;

    final response = await http.get(Uri.parse(AppUrl.countriesList));

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Error: failed to load data');
    }
  }
}