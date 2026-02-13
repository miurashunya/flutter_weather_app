# Flutter Weather App

現在地・保存した地域の天気情報をリアルタイムで取得・表示する Flutter アプリです。
天気の種類に応じたアニメーション背景が切り替わります。

---

## 画面・機能

- **現在地の天気取得** — 起動時・更新ボタン押下時に GPS で位置を取得し、天気情報を表示
- **天気アニメーション背景** — 晴れ・雨・雪・雷雨など天気に応じた背景アニメーションが自動切替
- **地域の保存** — 地名で検索した地域を登録し、SharedPreferences に永続保存
- **保存地域の天気表示** — 登録した地域をタップすると、その地域の天気をアニメーション付きで表示
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

フィーチャーベースのディレクトリ構成を採用しています。

```
lib/
├── main.dart
├── core/                                   # 複数フィーチャーで共有するコード
│   ├── models/
│   │   └── weather_model.dart              # WeatherModel, WeatherType enum
│   ├── services/
│   │   ├── weather_service.dart            # OpenWeatherMap API ラッパー
│   │   └── location_service.dart           # GPS・ジオコーディング
│   └── utils/
│       └── weather_type_extension.dart     # WeatherType 拡張（toScene()）
└── features/
    ├── home/                               # 現在地天気フィーチャー
    │   ├── viewmodels/
    │   │   ├── weather_state.dart          # WeatherState データクラス
    │   │   └── weather_view_model.dart     # WeatherViewModel (StateNotifier)
    │   └── views/
    │       ├── home_view.dart              # ホーム画面
    │       ├── weather_detail_view.dart    # 天気詳細画面
    │       ├── weather_samples_view.dart   # サンプル一覧画面（デバッグ）
    │       ├── weather_model_widget.dart   # 天気情報表示ウィジェット
    │       └── cloudy_widget.dart          # 曇り専用背景ウィジェット
    └── saved_locations/                    # 保存地域フィーチャー
        ├── models/
        │   └── saved_location.dart         # SavedLocation データクラス
        ├── services/
        │   └── saved_locations_service.dart # SharedPreferences CRUD
        ├── viewmodels/
        │   ├── saved_locations_view_model.dart   # 地域一覧の状態管理
        │   ├── location_search_view_model.dart   # 地名検索の状態管理
        │   └── location_weather_view_model.dart  # 特定地域の天気取得
        └── views/
            ├── saved_locations_view.dart   # 保存地域一覧画面
            ├── location_search_view.dart   # 地名検索・追加画面
            └── location_weather_view.dart  # 特定地域の天気表示画面
```

---

## アーキテクチャ

**MVVM + Riverpod** を採用しています。

### 画面遷移フロー

```
HomeView
  └─(リストアイコン)→ SavedLocationsView
                          └─(+ ボタン)→ LocationSearchView
                                            └─(地域タップ)→ 保存 → SavedLocationsView へ戻る
                          └─(地域タップ)→ LocationWeatherView
```

### データフロー

```
HomeView
  └─ watches weatherViewModelProvider
       └─ WeatherViewModel (StateNotifier)
            ├─ LocationService   → Geolocator で現在位置取得
            └─ WeatherService    → OpenWeatherMap API で天気取得
                  └─ IWeatherProvider（テスト時はフェイク実装に差替可）

LocationWeatherView
  └─ watches locationWeatherViewModelProvider(SavedLocation)
       └─ LocationWeatherViewModel (StateNotifier)
            └─ WeatherService    → 保存済み緯度経度で天気取得

SavedLocationsView
  └─ watches savedLocationsViewModelProvider
       └─ SavedLocationsViewModel (StateNotifier)
            └─ SavedLocationsService → SharedPreferences で地域を永続管理

LocationSearchView
  └─ watches locationSearchViewModelProvider
       └─ LocationSearchViewModel (StateNotifier)
            ├─ geocoding         → 地名 → 座標変換
            └─ SavedLocationsService → 地域の保存
```

### 状態管理

各フィーチャーの状態クラスと主なフィールドです。

**WeatherState**（現在地天気）

| フィールド | 型 | 説明 |
|---|---|---|
| `isLoading` | `bool` | データ取得中フラグ |
| `weather` | `WeatherModel?` | 取得済み天気データ |
| `error` | `String?` | エラーメッセージ |
| `locationName` | `String?` | 取得した地名（県・市）|
| `isPermissionPermanentlyDenied` | `bool` | パーミッション永続拒否フラグ |

**SavedLocationsState**（保存地域一覧）

| フィールド | 型 | 説明 |
|---|---|---|
| `locations` | `List<SavedLocation>` | 保存済み地域リスト |
| `isLoading` | `bool` | 読み込み中フラグ |
| `error` | `String?` | エラーメッセージ |

**LocationSearchState**（地名検索）

| フィールド | 型 | 説明 |
|---|---|---|
| `results` | `List<SavedLocation>` | 検索結果リスト |
| `isLoading` | `bool` | 検索中フラグ |
| `error` | `String?` | エラーメッセージ |

---

## 使用パッケージ

| パッケージ | 用途 |
|---|---|
| `flutter_riverpod` | 状態管理 |
| `flutter_dotenv` | 環境変数の読み込み |
| `geolocator` | GPS による現在位置取得 |
| `geocoding` | 座標 ↔ 住所変換 |
| `weather` | OpenWeatherMap API ラッパー |
| `weather_animation` | 天気アニメーション背景 |
| `shared_preferences` | 保存地域の永続化 |

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
