/// Groups thousands with dots, e.g. 23876000 -> "23.876.000".
String groupThousands(int value) {
  final digits = value.abs().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return '${value < 0 ? '-' : ''}$grouped';
}

/// Formats whole rupiah like "Rp 23.876.000".
String rupiah(int value) => 'Rp ${groupThousands(value)}';

String _two(int n) => n.toString().padLeft(2, '0');

/// Calendar day as "2026-10-06", the key used by every daily table.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

const _weekdayShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// Indonesian short weekday, e.g. "Sen".
String weekdayShort(DateTime d) => _weekdayShort[d.weekday - 1];

/// Clock time, e.g. "10:42". Accepts ISO-8601 text from the database.
String clockTime(String iso) {
  final d = DateTime.parse(iso);
  return '${_two(d.hour)}:${_two(d.minute)}';
}
