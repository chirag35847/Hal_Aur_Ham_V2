import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Weather {
  final int max;
  final int min;
  final int current;
  final String name;
  final String day;
  final int wind;
  final int humidity;
  final int chanceRain;
  final String image;
  final String time;
  final String location;

  Weather(
      {this.max,
      this.min,
      this.name,
      this.day,
      this.wind,
      this.humidity,
      this.chanceRain,
      this.image,
      this.current,
      this.time,
      this.location});
}

String appId = "74e0a709018250c0f7cbe8cfcc5e18fa";
Future<List> fetchData(String lat, String lon, String city) async {
  var url =
      "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&units=metric&appid=$appId";
  var response = await http.get(Uri.parse(url));
  DateTime date = DateTime.now();
  if (response.statusCode == 200) {
    var res = json.decode(response.body);
    //current Temp
    var current = res["current"];
    Weather currentTemp = Weather(
      current: current["temp"]?.round() ?? 0,
      name: current["weather"][0]["main"].toString(),
      day: DateFormat("EEEE dd MMMM").format(date),
      wind: current["wind_speed"]?.round() ?? 0,
      humidity: current["humidity"]?.round() ?? 0,
      chanceRain: current["uvi"]?.round() ?? 0,
      location: city,
      image: findIcon(
        current["weather"][0]["main"].toString(),
        true,
      ),
    );

    //today weather
    List<Weather> todayWeather = [];
    int hour = int.parse(DateFormat("hh").format(date));
    for (var i = 0; i < 4; i++) {
      var temp = res["hourly"];
      var hourly = Weather(
          current: temp[i]["temp"]?.round() ?? 0,
          image: findIcon(temp[i]["weather"][0]["main"].toString(), false),
          time: Duration(hours: hour + i + 1).toString().split(":")[0] + ":00");
      todayWeather.add(hourly);
    }

    //Tomorrow Weather
    var daily = res["daily"][0];
    Weather tomorrowTemp = Weather(
        max: daily["temp"]["max"]?.round() ?? 0,
        min: daily["temp"]["min"]?.round() ?? 0,
        image: findIcon(daily["weather"][0]["main"].toString(), true),
        name: daily["weather"][0]["main"].toString(),
        wind: daily["wind_speed"]?.round() ?? 0,
        humidity: daily["rain"]?.round() ?? 0,
        chanceRain: daily["uvi"]?.round() ?? 0);

    //Seven Day Weather
    List<Weather> sevenDay = [];
    for (var i = 1; i < 8; i++) {
      String day = DateFormat("EEEE")
          .format(DateTime(date.year, date.month, date.day + i + 1))
          .substring(0, 3);
      var temp = res["daily"][i];
      var hourly = Weather(
          max: temp["temp"]["max"]?.round() ?? 0,
          min: temp["temp"]["min"]?.round() ?? 0,
          image: findIcon(temp["weather"][0]["main"].toString(), false),
          name: temp["weather"][0]["main"].toString(),
          day: day);
      sevenDay.add(hourly);
    }
    return [currentTemp, todayWeather, tomorrowTemp, sevenDay];
  }
  return [null, null, null, null];
}

//findIcon
String findIcon(String name, bool type) {
  if (type) {
    switch (name) {
      case "Clouds":
        return "Assets/Images/sunny.png";
        break;
      case "Rain":
        return "Assets/Images/rainy.png";
        break;
      case "Drizzle":
        return "Assets/Images/rainy.png";
        break;
      case "Thunderstorm":
        return "Assets/Images/thunder.png";
        break;
      case "Snow":
        return "Assets/Images/snow.png";
        break;
      default:
        return "Assets/Images/sunny.png";
    }
  } else {
    switch (name) {
      case "Clouds":
        return "Assets/Images/sunny_2d.png";
        break;
      case "Rain":
        return "Assets/Images/rainy_2d.png";
        break;
      case "Drizzle":
        return "Assets/Images/rainy_2d.png";
        break;
      case "Thunderstorm":
        return "Assets/Images/thunder_2d.png";
        break;
      case "Snow":
        return "Assets/Images/snow_2d.png";
        break;
      default:
        return "Assets/Images/sunny_2d.png";
    }
  }
}
