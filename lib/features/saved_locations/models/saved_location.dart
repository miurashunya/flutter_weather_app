/// 保存済み地域情報を表すデータクラス
class SavedLocation {
  /// 一意識別子（ミリ秒タイムスタンプ文字列）
  final String id;

  /// 表示名（例: "東京都 新宿区"）
  final String name;

  /// 緯度
  final double latitude;

  /// 経度
  final double longitude;

  /// 保存済み地域情報を生成する
  ///
  /// [id] 一意識別子
  /// [name] 表示名
  /// [latitude] 緯度
  /// [longitude] 経度
  const SavedLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// JSONマップから [SavedLocation] を生成するファクトリーコンストラクタ
  ///
  /// [json] SharedPreferencesから読み込んだJSONマップ
  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// [SavedLocation] をJSONマップに変換する
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
