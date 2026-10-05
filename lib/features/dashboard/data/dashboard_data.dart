/// Mock data for the dashboard. Replace with SQLite or API data once those exist.
class ChannelSales {
  const ChannelSales({
    required this.day,
    required this.tokopedia,
    required this.shopee,
    required this.pos,
  });

  final String day;
  final double tokopedia;
  final double shopee;
  final double pos;

  double get total => tokopedia + shopee + pos;
}

class LiveOrder {
  const LiveOrder({
    required this.status,
    required this.platform,
    required this.item,
    required this.total,
    required this.time,
  });

  final String status;
  final String platform;
  final String item;
  final String total;
  final String time;
}

class DashboardData {
  DashboardData._();

  static const totalRevenue = 'Rp 23.876.000';
  static const deadstockSaved = 'Rp 1.450.000';
  static const activeChannels = '4 Platform';
  static const aiProductsLive = '12';
  static const syncStatus = 'Synced';
  static const efficiencyBadge = '+15% Efisiensi';

  static const tokopediaOrders = '24';
  static const shopeeOrders = '18';
  static const deadstockKg = '15 kg';

  static const aiAlertTitle = '⚠️ 15kg Roti Tawar Mendekati Kedaluwarsa!';
  static const aiAlertBody =
      'Jangan dibuang. AI kami menemukan 3 resep produk turunan berpotensi profit Rp 350.000.';
  static const aiAlertsCount = '3 AI Alerts';

  static const insightHeadline =
      'Bulan ini, AI berhasil menyelamatkan 15kg bahan baku menjadi margin profit tambahan Rp 450.000.';

  /// Shown after the photo analysis finishes.
  static const analysisResult =
      'AI menemukan 3 resep turunan dari bahan Anda: Muffin Roti Sisa, Crumble Roti, dan Pudding Roti. Potensi profit Rp 350.000.';

  static const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  static const channelSales = <ChannelSales>[
    ChannelSales(day: 'Sen', tokopedia: 12, shopee: 8, pos: 6),
    ChannelSales(day: 'Sel', tokopedia: 18, shopee: 10, pos: 7),
    ChannelSales(day: 'Rab', tokopedia: 15, shopee: 12, pos: 9),
    ChannelSales(day: 'Kam', tokopedia: 22, shopee: 14, pos: 8),
    ChannelSales(day: 'Jum', tokopedia: 28, shopee: 18, pos: 12),
    ChannelSales(day: 'Sab', tokopedia: 31, shopee: 22, pos: 15),
    ChannelSales(day: 'Min', tokopedia: 24, shopee: 19, pos: 11),
  ];

  /// Stock health score per day, 0 to 100.
  static const inventoryHealth = <double>[72, 68, 75, 70, 81, 79, 88];

  /// Share of raw materials sold or reused, in percent.
  static const wasteUsedPercent = 85;

  static const liveOrders = <LiveOrder>[
    LiveOrder(
      status: 'Dikemas',
      platform: 'Tokopedia',
      item: 'Muffin Roti Sisa - AI Recipe',
      total: 'Rp 85.000',
      time: '10:42',
    ),
    LiveOrder(
      status: 'Dikirim',
      platform: 'Shopee',
      item: 'Roti Tawar Potong Pinggir',
      total: 'Rp 32.000',
      time: '10:37',
    ),
    LiveOrder(
      status: 'Dikirim',
      platform: 'GoFood',
      item: 'Pudding Roti Gula Aren',
      total: 'Rp 28.000',
      time: '10:21',
    ),
    LiveOrder(
      status: 'Dikemas',
      platform: 'Offline',
      item: 'Crumble Roti - Paket 3',
      total: 'Rp 54.000',
      time: '09:58',
    ),
    LiveOrder(
      status: 'Selesai',
      platform: 'Shopee',
      item: 'Roti Sisa Mix Box',
      total: 'Rp 47.000',
      time: '09:12',
    ),
  ];
}
