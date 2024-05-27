import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/weather_model.dart';
import 'package:weather_app/weather_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearch = false;
  final TextEditingController _searchTextController = TextEditingController();

  // on pull down show search bar and on scroll down hide search bar
  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _isSearch = false;
      });
    }
    // on force pull down show search bar
    else if (_scrollController.position.pixels < 0.001) {
      setState(() {
        _isSearch = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // fetch weather data for current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeather('current');
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    String cityName = weatherProvider.weatherData?.name ?? '';
    int currTemp = weatherProvider.weatherData?.main?.temp?.round() ?? 0;
    int maxTemp = weatherProvider.weatherData?.main?.tempMax?.round() ?? 0;
    int minTemp = weatherProvider.weatherData?.main?.tempMin?.round() ?? 0;
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.01,
                    horizontal: size.width * 0.05,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.bars,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      Align(
                        child: Text(
                          'Weather App',
                          style: GoogleFonts.questrial(
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xff1D1617),
                            fontSize: size.height * 0.02,
                          ),
                        ),
                      ),
                      // Icon Button to search
                      _isSearch
                          ? const SizedBox()
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  _isSearch = !_isSearch;
                                });
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.magnifyingGlass,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                    ],
                  ),
                ),
                // Search bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearch ? size.height * 0.1 : 0,
                  clipBehavior: Clip.none,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: _isSearch
                        ? TextField(
                            controller: _searchTextController,
                            style: GoogleFonts.questrial(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search (e.g. Delhi or 700001,IN)',
                              hintStyle: GoogleFonts.questrial(
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                              ),
                              // input text style

                              suffixIcon: IconButton(
                                onPressed: () {
                                  // close keyboard
                                  FocusScope.of(context).unfocus();
                                  // check if search text is empty
                                  if (_searchTextController.text
                                      .trim()
                                      .isEmpty) {
                                    // show snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a city'),
                                      ),
                                    );
                                    return;
                                  }
                                  // fetch weather data
                                  weatherProvider.fetchWeather(
                                      _searchTextController.text.trim());
                                },
                                icon: FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
                if (weatherProvider.isLoading)
                  const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                else if (weatherProvider.weatherData == null)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Enter a city to get weather information',
                        style: GoogleFonts.questrial(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: size.height * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (weatherProvider.weatherData != null)
                  Flexible(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.03,
                            left: size.width * 0.05,
                            right: size.width * 0.05,
                          ),
                          child: Align(
                            child: Text(
                              cityName,
                              style: GoogleFonts.questrial(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: size.height * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.005,
                          ),
                          child: Align(
                            child: Text(
                              'Today', //day
                              style: GoogleFonts.questrial(
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                                fontSize: size.height * 0.035,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.03,
                          ),
                          child: Align(
                            child: Text(
                              '$currTemp˚C', //curent temperature
                              style: GoogleFonts.questrial(
                                color: currTemp <= 0
                                    ? Colors.blue
                                    : currTemp > 0 && currTemp <= 15
                                        ? Colors.indigo
                                        : currTemp > 15 && currTemp < 30
                                            ? Colors.deepPurple
                                            : Colors.pink,
                                fontSize: size.height * 0.13,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.25),
                          child: Divider(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.005,
                          ),
                          child: Align(
                            child: Text(
                              weatherProvider
                                      .weatherData?.weather?.first.main ??
                                  '', //weather description
                              style: GoogleFonts.questrial(
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                                fontSize: size.height * 0.03,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.03,
                            bottom: size.height * 0.01,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$minTemp˚C', // min temperature
                                style: GoogleFonts.questrial(
                                  color: minTemp <= 0
                                      ? Colors.blue
                                      : minTemp > 0 && minTemp <= 15
                                          ? Colors.indigo
                                          : minTemp > 15 && minTemp < 30
                                              ? Colors.deepPurple
                                              : Colors.pink,
                                  fontSize: size.height * 0.03,
                                ),
                              ),
                              Text(
                                '/',
                                style: GoogleFonts.questrial(
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                  fontSize: size.height * 0.03,
                                ),
                              ),
                              Text(
                                '$maxTemp˚C', //max temperature
                                style: GoogleFonts.questrial(
                                  color: maxTemp <= 0
                                      ? Colors.blue
                                      : maxTemp > 0 && maxTemp <= 15
                                          ? Colors.indigo
                                          : maxTemp > 15 && maxTemp < 30
                                              ? Colors.deepPurple
                                              : Colors.pink,
                                  fontSize: size.height * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: size.height * 0.01,
                                      left: size.width * 0.03,
                                    ),
                                    child: Text(
                                      'Forecast for today',
                                      style: GoogleFonts.questrial(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: size.height * 0.025,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(size.width * 0.005),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ...buildForecastTodayList(
                                            weatherProvider.weatherForecast
                                                    ?.weatherList ??
                                                []),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.02,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: Colors.white.withOpacity(0.05),
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: size.height * 0.02,
                                      left: size.width * 0.03,
                                    ),
                                    child: Text(
                                      '7-day forecast',
                                      style: GoogleFonts.questrial(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: size.height * 0.025,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(size.width * 0.005),
                                  child: Column(
                                    children: [
                                      //TODO: change weather forecast from local to api get
                                      buildSevenDayForecast(
                                        "Today", //day
                                        minTemp, //min temperature
                                        maxTemp, //max temperature
                                        FontAwesomeIcons.cloud, //weather icon
                                        size,
                                        isDarkMode,
                                      ),
                                      buildSevenDayForecast(
                                        "Wed",
                                        -5,
                                        5,
                                        FontAwesomeIcons.sun,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildSevenDayForecast(
                                        "Thu",
                                        -2,
                                        7,
                                        FontAwesomeIcons.cloudRain,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildSevenDayForecast(
                                        "Fri",
                                        3,
                                        10,
                                        FontAwesomeIcons.sun,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildSevenDayForecast(
                                        "San",
                                        5,
                                        12,
                                        FontAwesomeIcons.sun,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildSevenDayForecast(
                                        "Sun",
                                        4,
                                        7,
                                        FontAwesomeIcons.cloud,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildSevenDayForecast(
                                        "Mon",
                                        -2,
                                        1,
                                        FontAwesomeIcons.snowflake,
                                        size,
                                        isDarkMode,
                                      ),
                                      buildSevenDayForecast(
                                        "Tues",
                                        0,
                                        3,
                                        FontAwesomeIcons.cloudRain,
                                        size,
                                        isDarkMode,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildForecastToday(String time, int temp, int wind, int rainChance,
      IconData weatherIcon, size, bool isDarkMode) {
    // convert time to 12 hour format
    if (time == 'Now') {
      time = time;
    } else {
      time = DateTime.parse(time).hour > 12
          ? '${DateTime.parse(time).hour - 12} PM'
          : '${DateTime.parse(time).hour} AM';
    }
    return Padding(
      padding: EdgeInsets.all(size.width * 0.025),
      child: Column(
        children: [
          Text(
            time,
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.height * 0.02,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.005,
                ),
                child: FaIcon(
                  weatherIcon,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$temp˚C',
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.height * 0.025,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                ),
                child: FaIcon(
                  FontAwesomeIcons.wind,
                  color: Colors.grey,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$wind km/h',
            style: GoogleFonts.questrial(
              color: Colors.grey,
              fontSize: size.height * 0.02,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                ),
                child: FaIcon(
                  FontAwesomeIcons.umbrella,
                  color: Colors.blue,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$rainChance %',
            style: GoogleFonts.questrial(
              color: Colors.blue,
              fontSize: size.height * 0.02,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSevenDayForecast(String time, int minTemp, int maxTemp,
      IconData weatherIcon, size, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(
        size.height * 0.005,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                ),
                child: Text(
                  time,
                  style: GoogleFonts.questrial(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: size.height * 0.025,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.25,
                ),
                child: FaIcon(
                  weatherIcon,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: size.height * 0.03,
                ),
              ),
              Align(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: size.width * 0.15,
                  ),
                  child: Text(
                    '$minTemp˚C',
                    style: GoogleFonts.questrial(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontSize: size.height * 0.025,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                  ),
                  child: Text(
                    '$maxTemp˚C',
                    style: GoogleFonts.questrial(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: size.height * 0.025,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }

  List<Widget> buildForecastTodayList(List<WeatherList> list) {
    List<Widget> forecastList = [];
    Map<String, IconData> weatherIcons = {
      'Thunderstorm': FontAwesomeIcons.bolt,
      'Drizzle': FontAwesomeIcons.cloudRain,
      'Rain': FontAwesomeIcons.cloudShowersHeavy,
      'Snow': FontAwesomeIcons.snowflake,
      'Mist': FontAwesomeIcons.smog,
      'Smoke': FontAwesomeIcons.smog,
      'Haze': FontAwesomeIcons.smog,
      'Dust': FontAwesomeIcons.smog,
      'Fog': FontAwesomeIcons.smog,
      'Sand': FontAwesomeIcons.smog,
      'Ash': FontAwesomeIcons.smog,
      'Squall': FontAwesomeIcons.smog,
      'Tornado': FontAwesomeIcons.smog,
      'Clear Day': FontAwesomeIcons.sun,
      'Clear Night': FontAwesomeIcons.moon,
      'Clouds': FontAwesomeIcons.cloud,
    };
    for (int i = 0; i < list.length; i++) {
      forecastList.add(
        buildForecastToday(
          list[i].dtTxt ?? '',
          list[i].main?.temp?.round() ?? 0,
          list[i].wind?.speed?.round() ?? 0,
          list[i].clouds?.all ?? 0,
          weatherIcons[list[i].weather?.first.main ?? ''] ??
              (list[i].dtTxt!.contains('d')
                  ? FontAwesomeIcons.sun
                  : FontAwesomeIcons.moon),
          MediaQuery.of(context).size,
          MediaQuery.of(context).platformBrightness == Brightness.dark,
        ),
      );
    }
    return forecastList;
  }
}
