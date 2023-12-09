import 'package:path_provider/path_provider.dart';
import 'company_details.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' as io;

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
  Future<void> _openDB() async {
    if (io.Platform.isWindows || io.Platform.isLinux) {
      sqfliteFfiInit();
    }

    databaseFactory = databaseFactoryFfi;

    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final path = '${appDocumentsDir.path}/foodorigin.db';

    _db = await databaseFactory.openDatabase(path);
  }

  /// Returning a list of CompanyDetails matching the [searchStr]
  /// for the selected [country]
  Future<List<CompanyDetails>> getCompanyDetailList(
      String country, String searchStr) async {
    final list = await _queryDB(country, searchStr);

    if (list.isEmpty) {
      return [];
    }

    return List.generate(
      list.length,
      (index) => CompanyDetails(
        list[index]['name'] ?? '',
        list[index]['address'] ?? '',
        list[index]['approvalNo'] ?? '',
        list[index]['approvalNoOld'] ?? '',
        list[index]['comment'] ?? '',
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _queryDB(
      String country, String searchStr) async {
    try {
      final table = country.toLowerCase();
      final database = await db;
      final searchStr2 = searchStr.replaceAll(' ', '%');
      final map = await database.rawQuery(
        "SELECT DISTINCT * FROM '$table' WHERE approvalNo LIKE '%$searchStr%' OR approvalNoOld LIKE '%$searchStr%' OR name LIKE '%$searchStr2%' OR address LIKE '%$searchStr2%' ORDER BY approvalNo, approvalNoOld, name;",
      );
      return map;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getTableNames() async {
    try {
      final database = await db;
      final list = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      if (list.isEmpty) {
        return [];
      }

      final countries = list
          .map((item) => item['name']?.toString() ?? '')
          .toList()
          .cast<String>();
      countries.sort();

      return countries;
    } catch (e) {
      return [];
    }
  }
}
