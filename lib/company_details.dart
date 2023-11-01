import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contains the inforation on a single company
class CompanyDetails {
  /// The companies name
  final String name;

  /// The address
  final String address;

  /// The current approval no
  final String approvalNo;

  /// The old approval no
  final String approvalNoOld;

  /// Some comment
  final String comment;

  CompanyDetails(this.name, this.address, this.approvalNo, this.approvalNoOld,
      this.comment);

  @override
  String toString() {
    return '{name: $name, ??street: $address, ??appNo: $approvalNo, ??appNoOld: $approvalNoOld, ??comment: $comment}';
  }
}

/// The widget displaying the companydetails
class CompanyDetailsWidget extends StatelessWidget {
  final CompanyDetails companyDetails;

  const CompanyDetailsWidget(this.companyDetails, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(4.0),
        child: Card(
            elevation: 10,
            margin: const EdgeInsets.all(2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(
                title: Text(
                  companyDetails.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Icon(
                  Icons.house,
                  color: Colors.blue[500],
                  size: 40,
                ),
                subtitle: Text(companyDetails.address),
                // onTap: () {},
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Table(
                      columnWidths: const {
                        0: FractionColumnWidth(.4),
                        1: FractionColumnWidth(.6)
                      },
                      border: const TableBorder(
                          horizontalInside:
                              BorderSide(width: 1, color: Colors.white60)),
                      children: [
                        TableRow(children: [
                          TableCell(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, top: 10),
                                  child: const Text('Zul.-Nr.:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)))),
                          TableCell(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, top: 10),
                                  child: Text(companyDetails.approvalNo)))
                        ]),
                        if (companyDetails.approvalNoOld != '')
                          TableRow(children: [
                            TableCell(
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    child: const Text('Zul.-Nr. Alt:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)))),
                            TableCell(
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    child: Text(companyDetails.approvalNoOld)))
                          ]),
                        if (companyDetails.comment != '')
                          TableRow(children: [
                            TableCell(
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    child: const Text('Bemerkung:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)))),
                            TableCell(
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    child: Text(companyDetails.comment)))
                          ])
                      ])),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    child: const Text('Karte öffnen',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      try {
                        MapsLauncher.launchQuery(companyDetails.address);
                      } catch (e) {
                        _showDialog(
                            "Hinweis",
                            "'Ein Klick auf die Information sollte die Karten App (z.B. Google Maps) öffnen. Es sieht so aus, alsob keine Kartenapp installiert ist oder als solche verfügbar ist.'",
                            context);
                      }
                    },
                  ),
                  TextButton(
                    child: const Text('Websuche',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      Uri uri = Uri.https('www.google.com', '/search', {
                        'q': "${companyDetails.name}+${companyDetails.address}"
                      });
                      _openURL(uri.toString());
                    },
                  ),
                ],
              ),
            ])));
  }

  /// Open the url in the default browser
  void _openURL(String url) async {
    // if (await canLaunch(url)) {
    await launchUrl(Uri.parse(url));
    // } else {
    //   throw 'Could not launch $url';
    // }
  }
}

void _showDialog(String title, String message, BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hinweis'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
