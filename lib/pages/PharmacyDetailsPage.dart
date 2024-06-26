import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:well_connect_app/components/Ui.dart';
import 'package:well_connect_app/pages/Maps.dart';

class PharmacyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> pharmacyData;

  const PharmacyDetailsPage({Key? key, required this.pharmacyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUi screenUi = ScreenUi(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2b4260),
        title: Text(
          pharmacyData['name'],
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenUi.scaleWidth(16.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenUi.scaleWidth(10.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name: ${pharmacyData['name']}",
                            style: TextStyle(
                              fontSize: screenUi.scaleFontSize(16.0),
                              color: Color(0xff2b4260),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Maps(
                                    pharmacyLocation: pharmacyData['location'],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.location_on, color: Colors.red),
                            label: Text(
                              '',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenUi.scaleHeight(10.0)),
                      Text(
                        "Location: ${pharmacyData['location']}",
                        style: TextStyle(
                          fontSize: screenUi.scaleFontSize(14.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenUi.scaleHeight(20.0)),
              Text(
                "Available NCD medicines",
                style: TextStyle(
                  fontSize: screenUi.scaleFontSize(18.0),
                ),
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              _buildMedicineTable(pharmacyData['medicines'], context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineTable(List<dynamic>? medicines, BuildContext context) {
    ScreenUi screenUi = ScreenUi(context);
    if (medicines == null || medicines.isEmpty) {
      return Container(
          margin: EdgeInsets.only(top: 100),
          child: Center(
              child: Text(
            'No NCD medicines available',
            style: TextStyle(
              fontSize: screenUi.scaleFontSize(18.0),
              color: Colors.red,
            ),
          )));
    }

    return DataTable(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      columns: const [
        DataColumn(
            label:
                Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Medicine',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Price Tz',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: medicines
          .map((medicine) => _medicineDataRow(medicine, context))
          .toList(),
    );
  }

  DataRow _medicineDataRow(
      Map<String, dynamic> medicine, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(ClipOval(
          child: Image.asset(
            "lib/assets/bpmeds.png",
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        )),
        DataCell(GestureDetector(
          onTap: () {
            _showConfirmationDialog(context, medicine);
          },
          child: Text(medicine['medicine_name'] ?? 'Unknown'),
        )),
        DataCell(GestureDetector(
          onTap: () {
            _showConfirmationDialog(context, medicine);
          },
          child: Text(medicine['category'] ?? 'Unknown'),
        )),
        DataCell(GestureDetector(
          onTap: () {
            _showConfirmationDialog(context, medicine);
          },
          child: Text('${medicine['price'] ?? 'Unknown'}'),
        )),
      ],
    );
  }

  void _showConfirmationDialog(
      BuildContext context, Map<String, dynamic> medicine) {
    ScreenUi screenUi = ScreenUi(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add to Cart'),
          content: Text(
            'Do you want to add ${medicine['medicine_name']} to your cart?',
            style: TextStyle(
              fontSize: screenUi.scaleFontSize(16.0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel',  style: TextStyle(
                              fontSize: screenUi.scaleFontSize(16.0),
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),),
            ),
            TextButton(
              onPressed: () {
                _addToCart(medicine);
                Navigator.of(context).pop(true);
              },
              child: Text('OK',  style: TextStyle(
                              fontSize: screenUi.scaleFontSize(16.0),
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addToCart(Map<String, dynamic> medicine) async {
    String medicineName = medicine['medicine_name'];
    String pharmacyName = pharmacyData['name'];
    String pharmacyLocation = pharmacyData['location'];
    String medicinePrice = medicine['price'];
    String medicineCategory = medicine['category'];

    final data = {
      'medicineName': medicineName,
      'pharmacyName': pharmacyName,
      'pharmacyLocation': pharmacyLocation,
      'medicinePrice': medicinePrice,
      'medicineCategory': medicineCategory,
    };

    final result = await Api().postToCartData(route: '/addToCart', data: data);
    final response = jsonDecode(result.body);

    if (response['status']) {
      Fluttertoast.showToast(
        msg: "Added successfully to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to add to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }
}
