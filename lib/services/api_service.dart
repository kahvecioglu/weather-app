import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static Future getWeatherDataByCity(String city) async {
    return await http.get(
        Uri.parse(
            "https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$city"),
        headers: {
          HttpHeaders.authorizationHeader:
              'apikey 105pBmRaqEeEpRFPVuU64X:1p7WQU1hcyL2BSa2mx3aYo',
          HttpHeaders.contentTypeHeader: 'application/json'
        });
  }
}
