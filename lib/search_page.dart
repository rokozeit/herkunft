import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:herkunft/company_details.dart';
import 'package:herkunft/db_helper.dart';
import 'package:path_provider/path_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _filter = TextEditingController();

  String _searchText = "";

  String _selectedCountry = "DE";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: _getDrawer(context),
        appBar: AppBar(
          title: const Text('Food origin'),
          centerTitle: true,
        ),
        body: Scaffold(
            bottomNavigationBar: _getBottomAppBar(context),
            body: Container(
              child: _buildResult(),
            )));
  }

  _SearchPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  Widget _getDrawer(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Data import')),
          ListTile(
            title: const Text('Import data'),
            onTap: () async {},
          ),
        ],
      ),
    );
  }

  Widget _getBottomAppBar(BuildContext context) {
    return BottomAppBar(
        child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSearchFiled(),
                  _buildDropdown(),
                ])));
  }

  Widget _buildSearchFiled() {
    return Expanded(
        child: TextField(
            controller: _filter,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _searchText = "";
                        _filter.clear();
                      });
                    }))));
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
      value: _selectedCountry,
      icon: const Icon(Icons.expand_more),
      iconSize: 24,
      elevation: 16,
      underline: Container(
        height: 2,
      ),
      onChanged: (newValue) {
        setState(() {
          if (newValue != null) _selectedCountry = newValue;
        });
      },
      // items: <String>['DE', 'AT', 'IT', 'FR']
      items: <String>['DE', 'AT', 'CH', 'FR', 'IT']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildResult() {
    return FutureBuilder(
        future: existsDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == false) {
            return ListView(padding: const EdgeInsets.all(10.0), children: [
              InkWell(
                  child: const Center(
                      child: Text(
                    "No data base could be found. Import the health mark data base first by clicking here.",
                    textScaleFactor: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  )),
                  onTap: () => {
                        importDB(),
                      }),
              Container(
                  padding: const EdgeInsets.fromLTRB(100, 20, 100, 0),
                  child: Image.asset(
                    'assets/image.png',
                  )),
            ]);
          } else {
            if (_searchText == '') {
              return ListView(padding: const EdgeInsets.all(10.0), children: [
                const Center(
                    child: Text(
                  "Find food manufacturer via health mark",
                  textScaleFactor: 2,
                  textAlign: TextAlign.center,
                )),
                Container(
                    padding: const EdgeInsets.fromLTRB(100, 20, 100, 0),
                    child: Image.asset(
                      'assets/image.png',
                    )),
              ]);
            } else {
              return Scaffold(
                  body: FutureBuilder<List>(
                future: DBHelper.instance
                    .getCompanyDetailList(_selectedCountry, _searchText),
                initialData: List.empty(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, i) {
                      return CompanyDetailsWidget(snapshot.data?[i]);
                    },
                  );
                },
              ));
            }
          }
        });
  }

  Future<bool> existsDB() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String path = [appDocumentsDir.path, "foodorigin.db"].join('/');
    return File(path).exists();
  }

  importDB() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      String path = [appDocumentsDir.path, "foodorigin.db"].join('/');
      // Write and flush the bytes written
      await File(path).writeAsBytes(file.readAsBytesSync(), flush: true);
      setState(() {});
    } else {
      // User canceled the picker - nothing to do
    }
  }
}
