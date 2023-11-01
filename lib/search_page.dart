import 'package:flutter/material.dart';
import 'package:herkunft/company_details.dart';
import 'package:herkunft/db_helper.dart';

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
        // drawer: _getDrawer(context),
        appBar: AppBar(
          title: const Text('Herkunftssuche'),
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
              child: Text('Drawer Header')),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _getBottomAppBar(BuildContext context) {
    // final List<String> list = List.generate(10, (index) => "Text $index");

    return BottomAppBar(
        // notchMargin: 10,
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
      icon: const Icon(Icons.arrow_downward),
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
    if (_searchText == '') {
      return ListView(padding: const EdgeInsets.all(10.0), children: [
        const Center(
            child: Text(
          "Herstellersuche über die Zulassungsnummer",
          textScaleFactor: 2,
          textAlign: TextAlign.center,
        )),
        Container(
            padding: const EdgeInsets.fromLTRB(100, 20, 100, 0),
            child: Image.asset(
              'assets/image.png',
              // width: 300,
            )),
      ]);
    } else {
      return Scaffold(
          body: FutureBuilder<List>(
        future: DBHelper.instance
            .getCompanyDetailList(_selectedCountry, _searchText),
        initialData: List.empty(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, i) {
                return CompanyDetailsWidget(snapshot.data?[i]);
              },
            );
          } else {
            return Container(
                margin: const EdgeInsets.all(1),
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: const Text(
                              'Keine Einträge',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: const Icon(
                              Icons.error,
                              color: Colors.orange,
                              size: 40,
                            ),
                            subtitle: Text(
                                'Für die Zulassungsnummer "$_searchText" konnte kein Eintrag gefunden werden.'),
                            // onTap: () {},
                          )
                        ]))
                // child: CircularProgressIndicator(),
                );
          }
        },
      ));
    }
  }
}
