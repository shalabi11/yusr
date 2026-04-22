import 'package:hive/hive.dart';

class PrayerTimesCacheRecord {
  const PrayerTimesCacheRecord({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  factory PrayerTimesCacheRecord.fromMap(Map<String, dynamic> map) {
    return PrayerTimesCacheRecord(
      fajr: map['Fajr']?.toString() ?? '',
      sunrise: map['Sunrise']?.toString() ?? '',
      dhuhr: map['Dhuhr']?.toString() ?? '',
      asr: map['Asr']?.toString() ?? '',
      maghrib: map['Maghrib']?.toString() ?? '',
      isha: map['Isha']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }

  static PrayerTimesCacheRecord? fromDynamic(dynamic value) {
    if (value is PrayerTimesCacheRecord) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      return PrayerTimesCacheRecord.fromMap(value);
    }
    if (value is Map) {
      return PrayerTimesCacheRecord.fromMap(
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
    }
    return null;
  }
}

class PrayerTimesCacheRecordAdapter
    extends TypeAdapter<PrayerTimesCacheRecord> {
  @override
  final int typeId = 41;

  @override
  PrayerTimesCacheRecord read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final values = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimesCacheRecord(
      fajr: values[0]?.toString() ?? '',
      sunrise: values[1]?.toString() ?? '',
      dhuhr: values[2]?.toString() ?? '',
      asr: values[3]?.toString() ?? '',
      maghrib: values[4]?.toString() ?? '',
      isha: values[5]?.toString() ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimesCacheRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.fajr)
      ..writeByte(1)
      ..write(obj.sunrise)
      ..writeByte(2)
      ..write(obj.dhuhr)
      ..writeByte(3)
      ..write(obj.asr)
      ..writeByte(4)
      ..write(obj.maghrib)
      ..writeByte(5)
      ..write(obj.isha);
  }
}
