import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController controller = TextEditingController();
  List<dynamic> weatherData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(children: [
          TextField(
            controller: controller,
          ),
          ElevatedButton(onPressed: getWeather, child: Text("Get Weather")),
          Expanded(
              child: weatherData.isEmpty
                  ? Text("No Data")
                  : ListView.builder(
                      itemCount: weatherData.length,
                      itemBuilder: (context, index) {
                        String date = weatherData[index]['date'];
                        String morning = weatherData[index]['morning_forecast'];
                        String afternoon =
                            weatherData[index]['afternoon_forecast'];
                        String night = weatherData[index]['night_forecast'];
                        String summary = weatherData[index]['summary_forecast'];
                        return Card(
                            child: ListTile(
                          title: Text(date),
                          subtitle:
                              Text("$morning\n$afternoon\n$night\n$summary"),
                        ));
                      })),
        ]),
      ),
    );
  }

  Future<void> getWeather() async {
    String loc = controller.text;
    var response = await http.get(Uri.parse(
        'https://api.data.gov.my/weather/forecast/?contains=$loc@location__location_name'));
    log(response.body.toString());
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        weatherData = data;
      });
    }
  }
}
