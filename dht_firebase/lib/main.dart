import 'package:dht_firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference dhtRef = FirebaseDatabase.instance.ref("101/dht");
  final DatabaseReference relayRef = FirebaseDatabase.instance.ref("101/relay");

  double? temperature;
  double? humidity;
  int? relayStatus;

  @override
  void initState() {
    super.initState();

    dhtRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          temperature = (data["temperature"] as num?)?.toDouble();
          humidity = (data["humidity"] as num?)?.toDouble();
        });
      }
    });

    relayRef.onValue.listen((event) {
      final status = event.snapshot.value;
      setState(() {
        relayStatus = status is int ? status : int.tryParse(status.toString());
      });
    });
  }

  void toggleRelay(bool value) {
    final newStatus = value ? 1 : 0;
    relayRef.set(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final isRelayOn = relayStatus == 1;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DHT Sensor & Relay Monitor'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SensorCard(
              title: 'Temperature',
              value: temperature != null
                  ? "${temperature!.toStringAsFixed(1)} °C"
                  : "--",
              icon: Icons.thermostat,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            SensorCard(
              title: 'Humidity',
              value:
                  humidity != null ? "${humidity!.toStringAsFixed(1)} %" : "--",
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Relay Control",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Switch(
                      value: isRelayOn,
                      onChanged: toggleRelay,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                    Text(
                      "Relay is ${isRelayOn ? 'ON' : 'OFF'}",
                      style: TextStyle(
                        fontSize: 18,
                        color: isRelayOn ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        leading: Icon(icon, size: 40, color: color),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
