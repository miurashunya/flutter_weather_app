import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:weather/weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'GPS Weather API'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  //現在地取得のための変数
  double _latitude = 0.0;
  double _longitude = 0.0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getWeather,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  //位置情報取得のためのメソッド
  //https://zenn.dev/kazutxt/books/flutter_practice_introduction/viewer/23_chapter3_gps

  Future<void> getLocation() async {
    // 権限を取得
    LocationPermission permission = await Geolocator.requestPermission();
    // 権限がない場合は戻る
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('位置情報取得の権限がありません');
      return;
    }
    // 位置情報を取得
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      // 北緯がプラス、南緯がマイナス
      _latitude = position.latitude;
      // 東経がプラス、西経がマイナス
      _longitude = position.longitude;
      print('現在地の緯度は、$_latitude');
      print('現在地の経度は、$_longitude');
    });
    //取得した緯度経度からその地点の地名情報を取得する
    final placeMarks = await geoCoding.placemarkFromCoordinates(
      _latitude,
      _longitude,
    );
    final placeMark = placeMarks[0];
    print("現在地の国は、${placeMark.country}");
    print("現在地の県は、${placeMark.administrativeArea}");
    print("現在地の市は、${placeMark.locality}");
    // setState(() {
    //   Now_location = placeMark.locality ?? "現在地データなし";
    //   ref.read(riverpodNowLocation.notifier).state = Now_location;
    //   print('現在地は、$Now_location');
    // });
  }

  //天気情報を取得するためのメソッド
  //https://qiita.com/YoxMox/items/e29caf6ae8df2e55f0c4
  void getWeather() async {
    // 権限を取得
    LocationPermission permission = await Geolocator.requestPermission();
    // 権限がない場合は戻る
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('位置情報取得の権限がありません');
      return;
    }
    //エラー処理
    //https://eda-inc.jp/post-5028/#anchor-try-catch
    try {
      await getLocation();
      //https://api.openweathermap.org/data/2.5/weather?q=$location&appid=0651339b01382e4be760cc07ca9d8708
      // 24d72158c1394a66602789f58a4ff45e
      //自身のAPIキーを入力
      String key = "24d72158c1394a66602789f58a4ff45e";
      // double lat = 33.5487; //latitude(緯度)
      // double lon = 130.4629; //longitude(経度)
      double lat = _latitude; //latitude(緯度)
      double lon = _longitude; //longitude(経度)
      WeatherFactory wf = new WeatherFactory(key);

      Weather w = await wf.currentWeatherByLocation(lat, lon);

      print('天気情報は$w');
      print('天気は、${w.weatherMain}');
      print('天気(詳細)は、${w.weatherDescription}');
      print('気温は、${w.temperature}');
      print('体感温度は、${w.tempFeelsLike}');
      print('取得時間は、${w.date}');
      // print('天気情報2は$_data');
      // print('天気情報3は${ref.watch(weatherAPIdate)}');
    } catch (e) {
      //exceptionが発生した場合のことをかく
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // addBookToFirebase()のthrowで定義した文章を
            // e.toString()を使って表示している。
            title: AutoSizeText(
              '位置情報が取得できません！',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.pinkAccent,
              ),
              minFontSize: 10,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
            content: const AutoSizeText(
              '本アプリの位置情報の利用を許可して下さい',
              style: TextStyle(fontSize: 12.0),
              minFontSize: 10,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),

            actions: <Widget>[
              ElevatedButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
