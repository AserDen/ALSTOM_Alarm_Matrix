import 'package:drift/drift.dart';

class Faults extends Table {
  IntColumn get faultNumber => integer()(); // PK
  IntColumn get remoteAddressOctal => integer().nullable()();
  TextColumn get subset => text().nullable()();
  TextColumn get failureText => text()();

  TextColumn get alarmItem => text().nullable()();
  TextColumn get designation => text().nullable()();
  TextColumn get dcsGroup => text().nullable()();
  TextColumn get logic => text().nullable()();
  TextColumn get tempo => text().nullable()();
  TextColumn get condition => text().nullable()();

  TextColumn get rawJson => text()(); // всё остальное из Excel

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {faultNumber};
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get faultNumber => integer()();
  TextColumn get note => text()();
  TextColumn get author => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
