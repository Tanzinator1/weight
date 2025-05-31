// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyEntryAdapter extends TypeAdapter<DailyEntry> {
  @override
  final int typeId = 0;

  @override
  DailyEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyEntry(
      date: fields[0] as DateTime,
      weight: fields[1] as double,
      sleepHours: fields[2] as double,
      caloriesBreakfast: fields[3] as int,
      caloriesLunch: fields[4] as int,
      caloriesDinner: fields[5] as int,
      caloriesSnack: fields[6] as int,
      workoutCompleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DailyEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.sleepHours)
      ..writeByte(3)
      ..write(obj.caloriesBreakfast)
      ..writeByte(4)
      ..write(obj.caloriesLunch)
      ..writeByte(5)
      ..write(obj.caloriesDinner)
      ..writeByte(6)
      ..write(obj.caloriesSnack)
      ..writeByte(7)
      ..write(obj.workoutCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
