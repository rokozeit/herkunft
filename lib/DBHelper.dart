import 'package:flutter/services.dart';
import 'CompanyDetails.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'dart:io';

/// Helper querying the DB with the CompanyDetails
class DBHelper {
  /// The internal DB version managmenet
  /// should go up every time the DB is updated externally
  static const DB_VERSION = 1;

  /// The singleton instance
  static final DBHelper _instance = DBHelper();

  /// the db to be managed
  static Database _db;

  /// getter for the singleton
  static DBHelper get instance => _instance;

  Future<Database> get db async {
    if (_db == null) _db = await _openDB('assets/db.sqlite');
    return _db;
  }

  /// Every time the db is updated it is copied to the app folder.
  /// This is true for the first install as well.
  /// Version is controlled via the constant [DB_VERSION].
  Future<Database> _openDB(String assetDB) async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "foodorigin.db");

    // open existing db if it exists
    var db = await openDatabase(path);

    // Checke if new DB version is larger than existing one
    // if no db exists, the version will be 0
    if (await db.getVersion() < DB_VERSION) {
      // first close the db so it can be exchanged
      db.close();

      // This should only happen the first time the application is used
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(assetDB);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the data
      await File(path).writeAsBytes(bytes, flush: true);

      //open the newly created db
      db = await openDatabase(path);

      //set the new version to the copied db
      db.setVersion(DB_VERSION);
    } else {
      // just open the db
      db = await openDatabase(path);
    }
    // return db
    return db;
  }

  /// Returning a list of CompanyDetails matching the [searchStr]
  /// for the selected [country]
  Future<List<CompanyDetails>> getCompanyDetailList(
      String country, String searchStr) async {
    var list = await _queryDB(country, searchStr);

    if (list.isEmpty || list.length == 0) {
      return new List.empty();
    }

    List<CompanyDetails> approvalNos = List.generate(
        list.length,
        (index) => new CompanyDetails(
              list[index]['name'], // ?? '',
              list[index]['address'], // ?? '',
              list[index]['approvalNo'], // ?? '',
              list[index]['approvalNoOld'], // ?? '',
              list[index]['comment'], // ?? ''
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
      Database database = await this.db;
      List<Map> map = await database.rawQuery(
          'SELECT * FROM "$table" WHERE approvalNo LIKE "%$searchStr%" OR approvalNoOld LIKE "%$searchStr%" ORDER BY approvalNo, approvalNoOld, name;');
      return map;
    } catch (e) {
      // what should happen here?
      return new List.empty();
    }
  }
}
