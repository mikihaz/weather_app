import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '1f0487eee17ac19ca56dc058a04f7362';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> fetchWeather(String location) async {
    String url;
    // check if location is pincode
    if (int.tryParse(location.split(',')[0]) != null) {
      // check if location is in the format of pincode, country code
      if (location.split(',').length > 1) {
        url = '$_baseUrl/weather?zip=$location&appid=$_apiKey&units=metric';
      } else {
        url = '$_baseUrl/weather?zip=$location,in&appid=$_apiKey&units=metric';
      }
    } else {
      url = '$_baseUrl/weather?q=$location&appid=$_apiKey&units=metric';
    }
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> fetchForecast(String location) async {
    String url;
    // check if location is pincode
    if (int.tryParse(location.split(',')[0]) != null) {
      // check if location is in the format of pincode, country code
      if (location.split(',').length > 1) {
        url = '$_baseUrl/forecast?zip=$location&appid=$_apiKey&units=metric';
      } else {
        url = '$_baseUrl/forecast?zip=$location,in&appid=$_apiKey&units=metric';
      }
    } else {
      url = '$_baseUrl/forecast?q=$location&appid=$_apiKey&units=metric';
    }
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> fetchForecastByCoordinates(
      double lat, double lon) async {
    final url =
        '$_baseUrl/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByCoordinates(
      double lat, double lon) async {
    final url =
        '$_baseUrl/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
