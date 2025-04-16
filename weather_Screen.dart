import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Main weather screen widget (stateful)
class weatherScreen extends StatefulWidget {
  const weatherScreen({super.key});

  @override
  State<weatherScreen> createState() => _weatherScreenState();
}

class _weatherScreenState extends State<weatherScreen> {
  double temp = 0.0;
  bool isLoading = false;
  String condition = '';
  String iconCode = '';
  int humidity = 0;
  double windSpeed = 0.0;
  int pressure = 0;

  @override
  void initState() {
    super.initState();
    getCurrent(); // Fetch weather data on screen load
  }

  // Function to fetch current weather data
  Future getCurrent() async {
    try {
      setState(() {
        isLoading = true;
      });

      String city = 'Chennai';
      String key = 'YOUR_API_KEY'; // ← Replace with your actual API key

      final result = await http.get(
        Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=$city,in&APPID=$key&units=metric'),
      );

      final data = jsonDecode(result.body);
      if (data['cod'] != 200) {
        throw 'An error occurred: ${data['message']}';
      }

      setState(() {
        temp = data['main']['temp'];
        condition = data['weather'][0]['description'];
        iconCode = data['weather'][0]['icon'];
        humidity = data['main']['humidity'];
        windSpeed = data['wind']['speed'].toDouble();
        pressure = data['main']['pressure'];
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // UI builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CLIMATE CASTING",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'TimesNewRoman',
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: getCurrent, // Refresh weather data
            icon: const Icon(Icons.refresh),
          ),
        ],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader when fetching data
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          // Weather card
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 90,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '${temp.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (iconCode.isNotEmpty)
                          Image.network(
                            'http://openweathermap.org/img/wn/$iconCode@2x.png',
                            width: 90,
                            height: 90,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          condition.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'TimesNewRoman',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Climate forecast (sample hourly data)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Climate',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 7),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                hourly(time: '00.00', icon: Icons.sunny, temp: "33.5"),
                hourly(time: '12.00', icon: Icons.wb_cloudy, temp: "29.0"),
                hourly(time: '18.00', icon: Icons.grain, temp: "27.5"),
                hourly(time: '22.00', icon: Icons.mode_night, temp: "26.0"),
                hourly(time: '23.55', icon: Icons.foggy, temp: "25.0"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Additional info
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Additional Informations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          AddInformation(
            humidity: humidity,
            windSpeed: windSpeed,
            pressure: pressure,
          ),
        ]),
      ),
    );
  }
}

// Widget for hourly forecast cards
class hourly extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;

  const hourly({
    super.key,
    required this.time,
    required this.temp,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              temp,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for additional weather info (Humidity, Wind Speed, Pressure)
class AddInformation extends StatelessWidget {
  final int humidity;
  final double windSpeed;
  final int pressure;

  const AddInformation({
    super.key,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  // Method to build each info card
  Widget card({required IconData icon, required String label, required String value}) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, size: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(label, style: const TextStyle(fontSize: 20)),
            ),
            Text(value, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  // Layout for displaying all 3 info cards
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        card(icon: Icons.water_drop_outlined, label: "Humidity", value: "$humidity%"),
        card(icon: Icons.air, label: "Wind Speed", value: "${windSpeed.toStringAsFixed(1)} m/s"),
        card(icon: Icons.speed_rounded, label: "Pressure", value: "$pressure hPa"),
      ],
    );
  }
}
