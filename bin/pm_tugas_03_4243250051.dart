import 'dart:io';

// Satu baris data mata kuliah (record)
typedef MataKuliah = ({String nama, int sks, String nilai});

// Skala bobot (Spesifikasi 3: boleh pakai Map). Sesuaikan dengan pedoman akademik bila perlu.
const Map<String, int> skalaBobot = {'A': 4, 'B': 3, 'C': 2, 'D': 1, 'E': 0};

void main() {
  final data = <MataKuliah>[];
  print('Masukkan data mata kuliah. Kosongkan nama untuk selesai.');

  // Spesifikasi 1: input diulang, berhenti saat nama kosong
  while (true) {
    final nama = baca('Nama MK ');
    if (nama.isEmpty) break;

    // Spesifikasi 4: fungsi validasi melempar exception, main menangkapnya
    try {
      final sks = validasiSks(baca('SKS     '));
      final nilai = validasiNilai(baca('Nilai   '));
      data.add((nama: nama, sks: sks, nilai: nilai));
    } on FormatException catch (e) {
      print('Data diabaikan: ${e.message}');
    }
  }

  if (data.isEmpty) {
    print('Belum ada data mata kuliah.');
    return;
  }

  // Spesifikasi 6: KHS diurutkan dari nilai tertinggi
  cetakKhs(data, urutkan: true);

  final ip = hitungIp(data);
  print('Total SKS : ${jumlahSks(data)}');
  print('IP        : ${ip.toStringAsFixed(2)} (${predikat(ip)})');

  // Spesifikasi 5: mata kuliah berbobot < 2 ditampilkan dengan where
  final perbaiki = perluDiperbaiki(data);
  if (perbaiki.isNotEmpty) {
    print('Perlu diperbaiki: ${perbaiki.map((mk) => mk.nama).join(', ')}');
  }
}

/// Menampilkan label lalu membaca satu baris input.
String baca(String label) {
  stdout.write('$label: ');
  return (stdin.readLineSync() ?? '').trim();
}

/// Validasi SKS: harus angka 1-6, jika tidak lempar FormatException.
int validasiSks(String teks) {
  final sks = int.tryParse(teks);
  if (sks == null || sks < 1 || sks > 6) {
    throw FormatException('SKS harus berupa angka 1-6, bukan "$teks".');
  }
  return sks;
}

/// Validasi nilai huruf: harus A/B/C/D/E (huruf kecil diterima).
String validasiNilai(String teks) {
  final huruf = teks.toUpperCase();
  if (!skalaBobot.containsKey(huruf)) {
    throw FormatException('Nilai harus A, B, C, D, atau E, bukan "$teks".');
  }
  return huruf;
}

/// Mengubah nilai huruf menjadi bobot. Aman memakai "!" karena
/// nilai sudah divalidasi oleh validasiNilai().
int bobot(String huruf) => skalaBobot[huruf]!;

/// Menjumlahkan seluruh SKS memakai fold.
int jumlahSks(List<MataKuliah> data) =>
    data.fold<int>(0, (jumlah, mk) => jumlah + mk.sks);

/// IP = (jumlah SKS x bobot) / jumlah SKS, dihitung dengan fold.
double hitungIp(List<MataKuliah> data) {
  final totalSks = jumlahSks(data);
  if (totalSks == 0) return 0;
  final totalMutu = data.fold<int>(
    0,
    (jumlah, mk) => jumlah + mk.sks * bobot(mk.nilai),
  );
  return totalMutu / totalSks;
}

/// Predikat IP (skala contoh; sesuaikan dengan pedoman akademik Anda).
String predikat(double ip) {
  if (ip >= 3.5) return 'Sangat Memuaskan';
  if (ip >= 3.0) return 'Memuaskan';
  if (ip >= 2.0) return 'Cukup';
  return 'Kurang';
}

/// Mata kuliah dengan bobot < 2 (disaring dengan where).
List<MataKuliah> perluDiperbaiki(List<MataKuliah> data) =>
    data.where((mk) => bobot(mk.nilai) < 2).toList();

/// Mencetak KHS. Parameter bernama [urutkan]: true = nilai tertinggi di atas.
void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  final tampil = [...data]; // salinan, data asli tidak berubah
  if (urutkan) {
    // sort dengan fungsi pembanding: bobot terbesar lebih dulu
    tampil.sort((a, b) => bobot(b.nilai).compareTo(bobot(a.nilai)));
  }
  print('');
  print(_baris('Mata Kuliah', 'SKS', 'Nilai'));
  print('-' * 38);
  for (final mk in tampil) {
    print(_baris(mk.nama, mk.sks.toString(), mk.nilai));
  }
  print('-' * 38);
}

String _baris(String nama, String sks, String nilai) =>
    '${nama.padRight(24)}${sks.padRight(6)}$nilai';
