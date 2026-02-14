/// 現在時刻が夜（18時〜翌6時）かどうかを返す
bool isNightTime() {
  final hour = DateTime.now().hour;
  return hour >= 18 || hour < 6;
}
