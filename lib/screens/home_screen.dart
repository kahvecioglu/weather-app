import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/constant/colors.dart';
import 'package:weather_app/models/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = "";
  List<String> cities = [
    "Adana",
    "İstanbul",
    "Ankara",
    "İzmir",
    "Kars",
    "Mardin"
  ];
  List<Weather> weatherList = [];

  @override
  void initState() {
    getWeatherData('adana');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (weatherList.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: buildBackGroundColorGradient(weatherList[0].status),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: buildAppBarWidget(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Image.network(weatherList[0].icon,
                  width: MediaQuery.of(context).size.width / 3),
              const SizedBox(
                height: 5.0,
              ),
              Text(
                "${double.parse(weatherList[0].degree).round().toString()}°C",
                style: TextStyle(
                  fontSize: 70.0,
                  fontWeight: FontWeight.w300,
                  color: buildTextColor(weatherList[0].status),
                ),
              ),
              Text(
                weatherList[0].description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w300,
                  color: buildTextColor(weatherList[0].status),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: weatherList.length - 1,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Row(
                        children: [
                          // Gün adı için sabit genişlik
                          Expanded(
                            flex: 2, // Gün adının esnekliği
                            child: Text(
                              buildWeatherListText(weatherList[index + 1].day),
                              style: const TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          // İkon için sabit genişlik ve hizalama
                          // Sabit genişlik belirledik

                          // Resmi tam ortalar
                          Image.network(
                            weatherList[index + 1].icon,
                            height: 50,
                          ),

                          // Sıcaklıklar için sabit genişlik ve hizalama
                          Expanded(
                            flex: 2, // Sıcaklıklar için esneklik
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end, // Sağa hizalar
                              children: [
                                Text(
                                  "${double.parse(weatherList[index + 1].min).round()}°",
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  "${double.parse(weatherList[index + 1].max).round()}°",
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.transparent,
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

  List<Color> buildBackGroundColorGradient(String weather) {
    if (weather.toLowerCase() == "snow") {
      return [niceWhite, niceDarkBlue];
    } else if (weather.toLowerCase() == "rain") {
      return [niceVeryDarkBlue, niceDarkBlue];
    } else {
      return [niceBlue, niceDarkBlue];
    }
  }

  Color buildTextColor(String weather) {
    if (weather.toLowerCase() == "snow") {
      return niceTextDarkBlue;
    } else if (weather.toLowerCase() == "rain") {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  void getWeatherData(String cityData) {
    ApiService.getWeatherDataByCity(cityData).then((data) {
      Map resultBody = json.decode(data.body);
      if (resultBody['success'] == true) {
        setState(() {
          city = resultBody['city'];
          Iterable result = resultBody['result'];
          weatherList =
              result.map((watherData) => Weather(watherData)).toList();
        });
      }
    });
  }

  AppBar buildAppBarWidget() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weatherList[0].day,
            style: TextStyle(
              fontSize: 16.0,
              color: buildTextColor(weatherList[0].status),
            ),
          ),
          Text(
            weatherList[0].date,
            style: TextStyle(
              fontSize: 16.0,
              color: buildTextColor(weatherList[0].status),
            ),
          ),
        ],
      ),
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_pin,
                  color: buildTextColor(weatherList[0].status),
                ),
                PopupMenuButton<String>(
                  color: Colors.blue,
                  onSelected: (String selectedCity) {
                    setState(() {
                      city = selectedCity; // Seçilen şehri güncelle
                    });
                    getWeatherData(selectedCity
                        .toLowerCase()); // Seçilen şehrin verilerini al
                  },
                  itemBuilder: (BuildContext context) {
                    return cities.map((String listedCity) {
                      return PopupMenuItem<String>(
                        value: listedCity,
                        child: Text(
                          listedCity,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList();
                  },
                  child: Text(
                    city.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: buildTextColor(weatherList[0].status),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          width: 15.0,
        ),
      ],
    );
  }

  String buildWeatherListText(String day) {
    switch (day.toLowerCase()) {
      case "pazartesi":
        return "Pazartesi";
      case "salı":
        return "Salı           ";
      case "çarşamba":
        return "Çarşamba";
      case "perşembe":
        return "Perşembe";
      case "cuma":
        return "Cuma        ";
      case "cumartesi":
        return "Cumartesi   ";
      case "pazar":
        return "Pazar          ";
      default:
        return "?";
    }
  }
}
