// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_weather_app/main.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:flutter_weather_app/models/weather_model.dart';

class _FakeProvider implements IWeatherProvider {
  final WeatherModel model;
  _FakeProvider(this.model);
  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async => model;
}

void main() {
  testWidgets('HomeView shows instruction text', (WidgetTester tester) async {
    // Provide a fake WeatherService so widget build doesn't access dotenv or device APIs.
    final fakeModel = WeatherModel(
      weatherType: WeatherType.clear,
      description: 'clear sky',
    );
    final fakeService = WeatherService(_FakeProvider(fakeModel));

    // Build our app with ProviderScope overriding the weatherServiceProvider.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [weatherServiceProvider.overrideWithValue(fakeService)],
        child: const MyApp(),
      ),
    );

    // Verify that instruction text is shown.
    expect(find.text('ボタンを押して現在の天気を取得してください'), findsOneWidget);
  });
}
