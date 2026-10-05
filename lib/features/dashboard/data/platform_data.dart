import 'package:flutter/material.dart';

class AdKeyword {
  const AdKeyword({
    required this.keyword,
    required this.clicks,
    required this.spend,
    required this.roas,
  });

  final String keyword;
  final int clicks;
  final int spend;
  final String roas;
}

class PlatformAnalytics {
  const PlatformAnalytics({
    required this.name,
    required this.color,
    required this.overview,
    required this.conversionRate,
    required this.conversionNote,
    required this.visits,
    required this.keywords,
    required this.adsBudget,
    required this.adsSpent,
    required this.retentionLabels,
    required this.retentionValues,
    required this.retentionNote,
    required this.peakLabels,
    required this.peakValues,
    required this.peakNote,
    required this.autoReplyOn,
    required this.voucherOn,
  });

  final String name;
  final Color color;
  final String overview;
  final String conversionRate;
  final String conversionNote;
  final String visits;
  final List<AdKeyword> keywords;
  final int adsBudget;
  final int adsSpent;
  final List<String> retentionLabels;
  final List<double> retentionValues;
  final String retentionNote;
  final List<String> peakLabels;
  final List<double> peakValues;
  final String peakNote;
  final bool autoReplyOn;
  final bool voucherOn;
}

/// Mock platform data. Later these come from each platform's API.
class PlatformData {
  PlatformData._();

  static const tokopedia = PlatformAnalytics(
    name: 'Tokopedia',
    color: Color(0xFF23A97A),
    overview:
        'Tokopedia menyumbang 24 pesanan hari ini dengan rata-rata nilai keranjang Rp 48.000. Kanal ini paling kuat untuk produk roti utuh dan paket isi 3. Pembeli Tokopedia cenderung membandingkan harga, jadi promo voucher berpengaruh besar.',
    conversionRate: '3,8%',
    conversionNote:
        'Dari 12.400 kunjungan toko bulan ini, 472 berubah menjadi pesanan. Angka ini 0,6 poin di atas rata-rata kategori makanan.',
    visits: '12.400',
    keywords: [
      AdKeyword(
          keyword: 'roti sisa murah', clicks: 412, spend: 96000, roas: '4,2x'),
      AdKeyword(
          keyword: 'roti tawar sisa', clicks: 298, spend: 71000, roas: '3,6x'),
      AdKeyword(
          keyword: 'muffin roti', clicks: 176, spend: 44000, roas: '2,9x'),
      AdKeyword(
          keyword: 'pudding roti', clicks: 92, spend: 21000, roas: '1,8x'),
    ],
    adsBudget: 150000,
    adsSpent: 138000,
    retentionLabels: ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5', 'Mg 6'],
    retentionValues: [18, 22, 27, 31, 34, 38],
    retentionNote:
        '38% pembeli kembali dalam 6 minggu. Pembeli yang kembali biasanya memesan roti tawar dalam paket 3, jadi paket ini layak diberi voucher khusus.',
    peakLabels: ['08', '11', '14', '17', '20', '23'],
    peakValues: [4, 9, 6, 11, 18, 7],
    peakNote:
        'Puncak pesanan jatuh pukul 20.00 sampai 21.00 saat jam pulang kerja. Pastikan stok sudah dikemas sebelum pukul 19.00.',
    autoReplyOn: true,
    voucherOn: true,
  );

  static const shopee = PlatformAnalytics(
    name: 'Shopee',
    color: Color(0xFFF59E4B),
    overview:
        'Shopee menyumbang 18 pesanan hari ini. Pembeli Shopee lebih banyak menanyakan stok dan tanggal produksi lewat chat, sehingga auto-reply sangat membantu konversi.',
    conversionRate: '4,4%',
    conversionNote:
        'Dari 9.800 kunjungan toko, 431 berubah menjadi pesanan. Konversi chat naik ke 52% sejak auto-reply aktif.',
    visits: '9.800',
    keywords: [
      AdKeyword(keyword: 'roti sisa', clicks: 356, spend: 88000, roas: '3,9x'),
      AdKeyword(
          keyword: 'roti murah jakarta',
          clicks: 241,
          spend: 62000,
          roas: '3,1x'),
      AdKeyword(
          keyword: 'crumble roti', clicks: 134, spend: 30000, roas: '2,2x'),
      AdKeyword(
          keyword: 'kemasan box roti', clicks: 58, spend: 12000, roas: '1,4x'),
    ],
    adsBudget: 120000,
    adsSpent: 110400,
    retentionLabels: ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5', 'Mg 6'],
    retentionValues: [14, 19, 21, 24, 26, 29],
    retentionNote:
        '29% pembeli kembali dalam 6 minggu. Retensi Shopee lebih rendah dari Tokopedia, jadi fokus pada ulasan dan pesan terima kasih setelah pengiriman.',
    peakLabels: ['08', '11', '14', '17', '20', '23'],
    peakValues: [3, 7, 8, 9, 14, 10],
    peakNote:
        'Pesanan Shopee memuncak di siang hari (pukul 14.00) dan malam (pukul 20.00). Iklan sebaiknya dinaikkan pada dua jam itu.',
    autoReplyOn: true,
    voucherOn: false,
  );

  static PlatformAnalytics byName(String name) {
    return name == 'Shopee' ? shopee : tokopedia;
  }

  /// Formats a rupiah value like "Rp 150.000".
  static String rupiah(int value) {
    final digits = value.toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return 'Rp $grouped';
  }
}
