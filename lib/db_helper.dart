import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'company_details.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:path/path.dart' as p;
import 'dart:io' as io;

// import 'package:path_provider/path_provider.dart';

/// Helper querying the DB with the CompanyDetails
class DBHelper {
  /// The singleton instance
  static final DBHelper _instance = DBHelper();

  /// the db to be managed
  Database? _db;

  /// getter for the singleton
  static DBHelper get instance => _instance;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }

    await _openDB();
    return _db!;
  }

  /// https://blog.devgenius.io/adding-sqlite-db-file-from-the-assets-internet-in-flutter-3ec42c14cd44
  _openDB() async {
    if (io.Platform.isWindows || io.Platform.isLinux) {
      sqfliteFfiInit();
    }

    databaseFactory = databaseFactoryFfi;

    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();

    String path = [appDocumentsDir.path, "foodorigin.db"].join('/');

    bool dbExists = await io.File(path).exists();

    if (!dbExists) {
      // Copy from asset
      var assetDB = ["assets", "db.sqlite"].join('/');

      ByteData data = await rootBundle.load(assetDB);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await io.File(path).writeAsBytes(bytes, flush: true);
    }

    if (io.Platform.isWindows || io.Platform.isLinux) {
      _db = await databaseFactory.openDatabase(path);
    } else {
      _db = await databaseFactory.openDatabase(path);
    }
  }

  /// Returning a list of CompanyDetails matching the [searchStr]
  /// for the selected [country]
  Future<List<CompanyDetails>> getCompanyDetailList(
      String country, String searchStr) async {
    var list = await _queryDB(country, searchStr);

    if (list.isEmpty || list.isEmpty) {
      return List.empty();
    }

    List<CompanyDetails> approvalNos = List.generate(
        list.length,
        (index) => CompanyDetails(
              list[index]['name'] ?? '', // ?? '',
              list[index]['address'] ?? '', // ?? '',
              list[index]['approvalNo'] ?? '', // ?? '',
              list[index]['approvalNoOld'] ?? '', // ?? '',
              list[index]['comment'] ?? '', // ?? ''
            ));

    // approvalNos.forEach((element) {
    //   print(element);
    // });

    return approvalNos;
  }

  // A query to the DB
  Future<List<Map<dynamic, dynamic>>> _queryDB(
      String country, String searchStr) async {
    try {
      String table = country.toLowerCase();
      Database database = await db;

      // List<Map> map = await database.query(table,
      //     where:
      //         'approvalNo LIKE "%$searchStr%" OR approvalNoOld LIKE "%$searchStr%"',
      //     orderBy: 'approvalNo, approvalNoOld, name');

      List<Map> map = await database.rawQuery(
          "SELECT DISTINCT * FROM '$table' WHERE approvalNo LIKE '%$searchStr%' OR approvalNoOld LIKE '%$searchStr%' ORDER BY approvalNo, approvalNoOld, name;");
      return map;
    } catch (e) {
      // what should happen here?
      return List.empty();
    }
  }
}
