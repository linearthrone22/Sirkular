/// A user-defined automation rule shown on the dashboard cards.
/// Mock data for now. Later these will be stored in SQLite.
class UserRule {
  UserRule({
    required this.title,
    required this.condition,
    required this.action,
    required this.triggeredToday,
    this.isAi = false,
    this.active = true,
  });

  final String title;
  final String condition;
  final String action;
  final int triggeredToday;
  final bool isAi;
  bool active;
}

class UserRules {
  UserRules._();

  /// Fresh list each time, so toggles in one screen don't leak into another.
  static List<UserRule> defaults() => [
        UserRule(
          title: 'Restock otomatis',
          condition: 'stok tepung < 10 kg',
          action: 'buat PO ke supplier',
          triggeredToday: 1,
        ),
        UserRule(
          title: 'Diskon kedaluwarsa',
          condition: 'H-2 sebelum kedaluwarsa',
          action: 'diskon 30% di Shopee & Tokopedia',
          triggeredToday: 2,
        ),
        UserRule(
          title: 'Resep AI deadstock',
          condition: 'deadstock > 5 kg',
          action: 'buat resep turunan dengan AI',
          triggeredToday: 1,
          isAi: true,
        ),
      ];
}
