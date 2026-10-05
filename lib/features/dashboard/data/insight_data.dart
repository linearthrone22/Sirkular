import 'package:flutter/material.dart';

enum InsightTone { alert, info, success }

class Insight {
  const Insight({
    required this.title,
    required this.body,
    required this.icon,
    required this.tone,
    required this.action,
    required this.category,
  });

  final String title;
  final String body;
  final IconData icon;
  final InsightTone tone;
  final String action;
  final String category;
}

/// Mock insights. Later these come from the analysis backend.
class InsightData {
  InsightData._();

  static const items = <Insight>[
    Insight(
      title: 'Roti tawar mendekati kedaluwarsa',
      body:
          '15 kg expired dalam 2 hari. Diskon 30% disarankan untuk Shopee dan Tokopedia.',
      icon: Icons.schedule_rounded,
      tone: InsightTone.alert,
      action: 'Terapkan diskon',
      category: 'Stok',
    ),
    Insight(
      title: 'Resep turunan siap dibuat',
      body:
          'AI menemukan 3 resep dari bahan deadstock dengan potensi profit Rp 350.000.',
      icon: Icons.auto_awesome,
      tone: InsightTone.info,
      action: 'Lihat resep',
      category: 'AI R&D',
    ),
    Insight(
      title: 'Penjualan Tokopedia naik 15%',
      body: 'Sabtu jadi puncak pesanan. Tambah stok muffin untuk akhir pekan.',
      icon: Icons.trending_up_rounded,
      tone: InsightTone.success,
      action: 'Atur stok',
      category: 'Penjualan',
    ),
    Insight(
      title: 'Stok tepung hampir habis',
      body: 'Sisa 7 kg, cukup untuk 3 hari produksi. Buat PO sebelum Kamis.',
      icon: Icons.warning_amber_rounded,
      tone: InsightTone.alert,
      action: 'Buat PO',
      category: 'Stok',
    ),
    Insight(
      title: 'Iklan Shopee cepat habis',
      body:
          'Anggaran iklan sudah terpakai 92% sebelum sore. Turunkan bid kata kunci "roti sisa".',
      icon: Icons.campaign_outlined,
      tone: InsightTone.info,
      action: 'Buka iklan',
      category: 'Iklan',
    ),
    Insight(
      title: 'Deadstock terselamatkan',
      body: '15 kg bahan berhasil dijual ulang bulan ini, setara Rp 1.450.000.',
      icon: Icons.eco_outlined,
      tone: InsightTone.success,
      action: 'Lihat laporan',
      category: 'Sirkular',
    ),
    Insight(
      title: 'Susu UHT hampir expired',
      body:
          '4 L susu sisa 3 hari lagi. Jadikan Pudding Roti untuk menghabiskan stok.',
      icon: Icons.local_drink_outlined,
      tone: InsightTone.info,
      action: 'Buat resep',
      category: 'Stok',
    ),
    Insight(
      title: 'Konversi chat Shopee membaik',
      body: 'Auto-reply menaikkan konversi chat dari 40% ke 52% minggu ini.',
      icon: Icons.chat_bubble_outline_rounded,
      tone: InsightTone.success,
      action: 'Lihat detail',
      category: 'Pelanggan',
    ),
  ];
}
