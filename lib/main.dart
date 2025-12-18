import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController =
      TextEditingController(text: 'Tokyo');
  Map<String, dynamic>? _weather;
  bool _loading = false;
  String? _error;

  Future<void> _fetchWeather(String city) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() => _error = 'OPENWEATHER_API_KEY が .env に設定されていません。');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _weather = null;
    });

    try {
      final uri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&units=metric&appid=$apiKey');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => _weather = json);
      } else {
        setState(() => _error = 'API error: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _error = '通信エラー: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildWeatherCard() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_weather == null) {
      return const Center(child: Text('都市名を入力して「取得」ボタンを押してください。'));
    }

    final name = _weather!['name'] ?? '';
    final main = _weather!['main'] ?? {};
    final temp = main['temp']?.toString() ?? '—';
    final humidity = main['humidity']?.toString() ?? '—';
    final weatherList = _weather!['weather'] as List<dynamic>?;
    final desc = (weatherList != null && weatherList.isNotEmpty)
        ? weatherList[0]['description']
        : '—';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$temp °C', style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('湿度: $humidity%'),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeySet = dotenv.env['OPENWEATHER_API_KEY'] != null &&
        dotenv.env['OPENWEATHER_API_KEY']!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('OpenWeatherMap Demo')),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                      labelText: '都市名', border: OutlineInputBorder()),
                  onSubmitted: (v) => _fetchWeather(v.trim()),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: apiKeySet
                    ? () => _fetchWeather(_cityController.text.trim())
                    : null,
                child: const Text('取得'),
              ),
            ]),
          ),
          if (!apiKeySet)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '.env に OPENWEATHER_API_KEY=あなたのAPIキー を追加してください。',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildWeatherCard()),
        ]),
      ),
    );
  }
}
