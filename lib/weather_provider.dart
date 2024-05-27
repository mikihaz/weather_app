import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:weather_app/geolocator_service.dart';
import 'weather_service.dart';
import 'weather_model.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  WeatherForecast? _weatherForecast;
  bool _isLoading = false;
  String? _errorMessage;
  final HashMap<String, WeatherData> _cacheWeatherData = HashMap();
  final HashMap<String, WeatherForecast> _cacheWeatherForecast = HashMap();

  WeatherData? get weatherData => _weatherData;
  WeatherForecast? get weatherForecast => _weatherForecast;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather(String location) async {
    // check if the location is curreent location
    if (location == 'current') {
      // check if the weather data is already in the cache
      if (_cacheWeatherData.containsKey(location) &&
          _cacheWeatherForecast.containsKey(location)) {
        _weatherData = _cacheWeatherData[location];
        _weatherForecast = _cacheWeatherForecast[location];
        notifyListeners();
        return;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        // get the current location
        final position = await GeolocatorService.determinePosition();
        // get the current location weather data
        final weatherData = await WeatherService()
            .fetchWeatherByCoordinates(position.latitude, position.longitude);
        final forecastData = await WeatherService()
            .fetchForecastByCoordinates(position.latitude, position.longitude);
        _weatherData = WeatherData.fromJson(weatherData);
        _weatherForecast = WeatherForecast.fromJson(forecastData);
        _cacheWeatherData[location] = _weatherData!;
        _cacheWeatherForecast[location] = _weatherForecast!;
      } catch (e) {
        _errorMessage = 'Failed to load weather data';
      }

      _isLoading = false;
      notifyListeners();
      return;
    } else {
      // Check if the weather data is already in the cache
      if (_cacheWeatherData.containsKey(location) &&
          _cacheWeatherForecast.containsKey(location)) {
        _weatherData = _cacheWeatherData[location];
        _weatherForecast = _cacheWeatherForecast[location];
        notifyListeners();
        return;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        final weatherData = await WeatherService().fetchWeather(location);
        final forecastData = await WeatherService().fetchForecast(location);
        _weatherData = WeatherData.fromJson(weatherData);
        _weatherForecast = WeatherForecast.fromJson(forecastData);
        _cacheWeatherData[location] = _weatherData!;
        _cacheWeatherForecast[location] = _weatherForecast!;
      } catch (e) {
        _errorMessage = 'Failed to load weather data';
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
