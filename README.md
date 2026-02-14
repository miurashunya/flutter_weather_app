# Flutter Weather App

現在地・保存した地域の天気情報をリアルタイムで取得・表示する Flutter アプリです。
天気の種類に応じたアニメーション背景が切り替わります。

---

## 画面・機能

- **現在地の天気取得** — 起動時・更新ボタン押下時に GPS で位置を取得し、天気情報を表示
- **天気アニメーション背景** — 晴れ・雨・雪・雷雨など天気に応じた背景アニメーションが自動切替
- **昼夜アニメーション切替** — 18時〜翌6時は夜モードに切替（晴れ夜は星空＋三日月、他天気は夜色背景）
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
│   │   ├── location_service.dart           # GPS による現在位置取得
│   │   └── geocoding_service.dart          # ジオコーディング（プラットフォーム切替）
│   └── utils/
│       ├── weather_type_extension.dart     # WeatherType 拡張（toScene()）
│       └── time_of_day_utils.dart          # 昼夜判定ユーティリティ
└── features/
    ├── home/                               # 現在地天気フィーチャー
    │   ├── viewmodels/
    │   │   ├── weather_state.dart          # WeatherState データクラス（UI状態）
    │   │   └── weather_view_model.dart     # WeatherViewModel (StateNotifier)
    │   └── views/
    │       ├── home_view.dart              # ホーム画面
    │       ├── weather_model_widget.dart   # 天気情報表示ウィジェット
    │       ├── weather_widgets/            # 天気別背景アニメーションウィジェット
    │       │   ├── sunny_widget.dart       # 晴れ（水色背景＋単色太陽＋光線）
    │       │   ├── night_widget.dart       # 晴れ夜（星空＋三日月）
    │       │   ├── cloudy_widget.dart      # 曇り（昼: グレー / 夜: 紺色）
    │       │   ├── rainy_widget.dart       # 雨・霧雨（昼夜切替）
    │       │   ├── stormy_widget.dart      # 雷雨（昼夜切替）
    │       │   ├── snowy_widget.dart       # 雪（昼夜切替）
    │       │   └── misty_widget.dart       # 霧・その他（昼夜切替）
    │       └── test_widgets/              # デバッグ専用画面
    │           ├── weather_detail_view.dart  # 天気詳細画面
    │           └── weather_samples_view.dart # サンプル一覧画面
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

## 天気アニメーション背景

天気タイプと時刻（昼夜）の組み合わせで背景ウィジェットを切り替えます。

### 昼夜判定

`isNightTime()` 関数が `DateTime.now().hour` を参照し、**18時〜翌6時**を夜と判定します。

### 切替テーブル

| 天気タイプ | 昼（6時〜18時） | 夜（18時〜6時） |
|---|---|---|
| 晴れ | `SunnyWidget`（水色背景・単色太陽・光線アニメ） | `NightWidget`（星空・三日月） |
| 曇り | `CloudyWidget`（グレー背景・白い雲） | `CloudyWidget`（紺色背景・青みがかった雲） |
| 雨・霧雨 | `RainyWidget`（デフォルト色） | `RainyWidget`（暗いスレートブルー） |
| 雷雨 | `StormyWidget`（デフォルト色） | `StormyWidget`（ほぼ漆黒） |
| 雪 | `SnowyWidget`（デフォルト色） | `SnowyWidget`（暗い冬の夜空） |
| 霧・その他 | `MistyWidget`（デフォルト色） | `MistyWidget`（深夜ブルー） |

### カスタムウィジェットの仕様

**`SunnyWidget`**
- `WrapperScene` に水色グラデーション背景を設定
- `SunWidget` のコア・中間・外側リングを同色に統一して単色に表示
- `_SunRaysWidget`（`Ticker` ベース）で光線を描画。各光線がランダムな角速度・位相で独立して伸縮

**`NightWidget`**
- 深い紺色グラデーション背景
- `_MoonPainter`（`CustomPaint`）: `saveLayer` + `BlendMode.clear` で三日月を描画
- `_StarsWidget`（`Ticker` ベース）: 70個の星がそれぞれ独立したタイミングでまたたく

**`CloudyWidget`（夜モード）**
- `isNight` パラメータで背景色と雲の色を切り替え

**`RainyWidget` / `StormyWidget` / `SnowyWidget` / `MistyWidget`**
- `WrapperScene.weather(scene: ..., colors: isNight ? nightColors : null)` で昼夜の背景色を切り替え
- アニメーション内容（雨粒・雷・雪など）はそのまま維持

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
            ├─ LocationService      → Geolocator で現在位置取得
            │     └─ GeocodingService → 座標 → 地名変換（リバースジオコーディング）
            └─ WeatherService       → OpenWeatherMap API で天気取得
                  └─ IWeatherProvider（テスト時はフェイク実装に差替可）

LocationWeatherView
  └─ watches locationWeatherViewModelProvider(SavedLocation)
       └─ LocationWeatherViewModel (StateNotifier)
            └─ WeatherService       → 保存済み緯度経度で天気取得

SavedLocationsView
  └─ watches savedLocationsViewModelProvider
       └─ SavedLocationsViewModel (StateNotifier)
            └─ SavedLocationsService → SharedPreferences で地域を永続管理

LocationSearchView
  └─ watches locationSearchViewModelProvider
       └─ LocationSearchViewModel (StateNotifier)
            ├─ GeocodingService   → 地名 → 座標変換（OWM Geocoding API）
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
| `geolocator` | GPS による現在位置取得（全プラットフォーム対応）|
| `geocoding` | 座標 → 住所変換（Android・iOS・macOS のみ使用）|
| `weather` | OpenWeatherMap API ラッパー |
| `weather_animation` | 天気アニメーション背景 |
| `shared_preferences` | 保存地域の永続化 |
| `http` | OWM Geocoding API 呼び出し（Windows・Web のフォールバック）|

---

## プラットフォーム対応

| 機能 | Android / iOS / macOS | Windows | Web |
|---|---|---|---|
| 現在地取得 | ✅ | ✅ | ✅（ブラウザ許可が必要）|
| 地名表示（リバースジオコーディング）| ✅ `geocoding` パッケージ | ✅ OWM API | ✅ OWM API |
| 地名検索（フォワードジオコーディング）| ✅ OWM API | ✅ OWM API | ✅ OWM API |
| 設定アプリへの誘導ボタン | ✅ | ✅ | — （非対応のため非表示）|

> **Windows での位置情報**: システム設定 → プライバシーとセキュリティ → 位置情報 でアプリのアクセスを許可してください。
>
> **Web でのビルド**: `flutter run -d chrome` で起動できます。位置情報は `https` または `localhost` 環境でのみ取得可能です。
>
> **ジオコーディングの精度**: Windows・Web では `geocoding` パッケージの代わりに OWM Geocoding API を使用するため、日本語の都道府県名が取得できない場合があります。

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
