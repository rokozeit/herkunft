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
  _openDB() async {
    if (io.Platform.isWindows || io.Platform.isLinux) {
      sqfliteFfiInit();
    }

    databaseFactory = databaseFactoryFfi;

    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();

    String path = [appDocumentsDir.path, "foodorigin.db"].join('/');

    _db = await databaseFactory.openDatabase(path);
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

    return approvalNos;
  }

  // A query to the DB
  Future<List<Map<dynamic, dynamic>>> _queryDB(
      String country, String searchStr) async {
    try {
      String table = country.toLowerCase();
      Database database = await db;
      String searchStr2 = searchStr.replaceAll(" ", "%");
      List<Map> map = await database.rawQuery(
          "SELECT DISTINCT * FROM '$table' WHERE approvalNo LIKE '%$searchStr%' OR approvalNoOld LIKE '%$searchStr%'  OR name LIKE '%$searchStr2%'  OR address LIKE '%$searchStr2%' ORDER BY approvalNo, approvalNoOld, name;");
      return map;
    } catch (e) {
      // what should happen here?
      return List.empty();
    }
  }

  Future<List<String>> getTableNames() async {
    try {
      Database database = await db;
      List<Map> list = await database
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

      if (list.isEmpty || list.isEmpty) {
        return List.empty();
      }

      List<String> countries = List.generate(
        list.length,
        (index) => list[index]['name'] ?? '', // ?? '',
      );

      countries.sort((a, b) => a.compareTo(b));

      return countries;
    } catch (e) {
      // what should happen here?
      return List.empty();
    }
  }
}
