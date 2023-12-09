import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetails {
  final String name;
  final String address;
  final String approvalNo;
  final String approvalNoOld;
  final String comment;

  CompanyDetails(
    this.name,
    this.address,
    this.approvalNo,
    this.approvalNoOld,
    this.comment,
  );

  @override
  String toString() {
    return '{name: $name, street: $address, appNo: $approvalNo, appNoOld: $approvalNoOld, comment: $comment}';
  }
}

class CompanyDetailsWidget extends StatelessWidget {
  final CompanyDetails companyDetails;

  const CompanyDetailsWidget(this.companyDetails, {Key? key}) : super(key: key);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                companyDetails.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const Icon(
                Icons.house,
                color: Colors.black54,
                size: 40,
              ),
              subtitle: Text(companyDetails.address),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Table(
                columnWidths: const {
                  0: FractionColumnWidth(.4),
                  1: FractionColumnWidth(.6)
                },
                border: const TableBorder(
                  horizontalInside: BorderSide(width: 1, color: Colors.white60),
                ),
                children: [
                  _buildTableRow(
                    'Health mark:',
                    companyDetails.approvalNo,
                  ),
                  if (companyDetails.approvalNoOld.isNotEmpty)
                    _buildTableRow(
                      'Health mark (old):',
                      companyDetails.approvalNoOld,
                    ),
                  if (companyDetails.comment.isNotEmpty)
                    _buildTableRow(
                      'Comment:',
                      companyDetails.comment,
                    ),
                ],
              ),
            ),
            ButtonBar(
              children: <Widget>[
                _buildTextButton(
                  'Open on map',
                  () {
                    _launchMap(companyDetails.address, context);
                  },
                ),
                _buildTextButton(
                  'Web search',
                  () {
                    _openWebSearch(companyDetails.name, companyDetails.address);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextButton _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  void _launchMap(String address, BuildContext context) {
    try {
      MapsLauncher.launchQuery(address);
    } catch (e) {
      _showDialog(
        "Remark",
        "Should open the map app if configured correctly. Looks like there was an issue.",
        context,
      );
    }
  }

  void _openWebSearch(String name, String address) {
    final query = '$name+$address';
    final url = 'https://www.google.com/search?q=$query';

    _openURL(url);
  }

  Future<void> _openURL(String url) async {
    await launchUrl(Uri.parse(url));
  }

  void _showDialog(String title, String message, BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
}
