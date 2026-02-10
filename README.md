# Flutter Weather App

現在地の天気情報をリアルタイムで取得・表示する Flutter アプリです。
天気の種類に応じたアニメーション背景が切り替わります。

---

## 画面・機能

- **現在地の天気取得** — 起動時・更新ボタン押下時に GPS で位置を取得し、天気情報を表示
- **天気アニメーション背景** — 晴れ・雨・雪・雷雨など天気に応じた背景アニメーションが自動切替
- **天気サンプル一覧**（デバッグ時のみ）— 全天気種別のアニメーションをプレビューできる画面

---

## セットアップ

### 必要環境

- Flutter SDK（最新安定版推奨）
- OpenWeatherMap API キー（無料プランで取得可能）

### 1. 依存パッケージのインストール

```bash
flutter pub get
```

### 2. 環境変数ファイルの作成

プロジェクトルートに `.env` ファイルを作成し、API キーを記載します。

```text
OPENWEATHER_API_KEY=your_api_key_here
```

> **注意:** `.env` はバージョン管理対象外です（`.gitignore` で除外済み）。
> API キーは [OpenWeatherMap](https://openweathermap.org/api) から取得してください。

### 3. アプリの起動

```bash
flutter run
```

---

## プロジェクト構成

```
lib/
├── main.dart                        # エントリーポイント
├── models/
│   └── weather_model.dart           # WeatherModel, WeatherType enum
├── services/
│   ├── weather_service.dart         # OpenWeatherMap API ラッパー
│   └── location_service.dart        # GPS・ジオコーディング
├── viewmodels/
│   └── weather_view_model.dart      # WeatherViewModel (StateNotifier)
├── views/
│   ├── home_view.dart               # ホーム画面
│   ├── weather_detail_view.dart     # 天気詳細画面
│   ├── weather_samples_view.dart    # サンプル一覧画面（デバッグ）
│   ├── weather_model_widget.dart    # 天気情報表示ウィジェット
│   └── cloudy_widget.dart           # 曇り専用背景ウィジェット
└── utils/
    └── weather_type_extension.dart  # WeatherType 拡張（toScene()）
```

---

## アーキテクチャ

**MVVM + Riverpod** を採用しています。

```
HomeView
  └─ watches weatherViewModelProvider
       └─ WeatherViewModel (StateNotifier)
            ├─ LocationService  → Geolocator で現在位置取得
            └─ WeatherService   → OpenWeatherMap API で天気取得
                  └─ IWeatherProvider (テスト時はフェイク実装に差替可)
```

### 状態管理

`WeatherState` が以下の3つの状態を持ちます。

| フィールド | 型 | 説明 |
|---|---|---|
| `isLoading` | `bool` | データ取得中フラグ |
| `weather` | `WeatherModel?` | 取得済み天気データ |
| `error` | `String?` | エラーメッセージ |

---

## 使用パッケージ

| パッケージ | 用途 |
|---|---|
| `flutter_riverpod` | 状態管理 |
| `flutter_dotenv` | 環境変数の読み込み |
| `geolocator` | GPS による現在位置取得 |
| `geocoding` | 座標 → 住所変換 |
| `weather` | OpenWeatherMap API ラッパー |
| `weather_animation` | 天気アニメーション背景 |

---

## テスト

```bash
# 全テスト実行
flutter test

# 特定ファイルのみ実行
flutter test test/weather_service_test.dart
```

テストでは `IWeatherProvider` にフェイク実装を注入して API 通信なしで動作確認できます。

```dart
final fakeService = WeatherService(FakeProvider());
```

---

## 参考

- [OpenWeatherMap API ドキュメント](https://openweathermap.org/api)
- [参考記事](https://zenn.dev/amuro/articles/96f61aff90e9da)
