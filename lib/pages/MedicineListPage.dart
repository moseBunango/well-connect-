import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:well_connect_app/components/Ui.dart';

class MedicineListsPage extends StatefulWidget {
  final Map<String, dynamic> medicineData;

  const MedicineListsPage({Key? key, required this.medicineData})
      : super(key: key);

  @override
  State<MedicineListsPage> createState() => _MedicineListsPageState();
}

class _MedicineListsPageState extends State<MedicineListsPage> {
  Future<bool> _onWillPop() async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Do you really want to exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    return shouldLogout;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUi screenUi = ScreenUi(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2b4260),
        title: Text(
          widget.medicineData['medicine_name'],
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        // Allow scrolling if content overflows
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to left
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xff2b4260),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        Text("Name: ${widget.medicineData['medicine_name']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenUi.scaleFontSize(18.0),
                                color: Colors.white)),
                        SizedBox(height: screenUi.scaleHeight(10.0)),
                        Text(
                          "Price: TZS${widget.medicineData['price']}/=",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenUi.scaleFontSize(18.0),
                              color: Colors.white),
                        ),
                      ]),
                      Column(children: [
                        Text("Category: ${widget.medicineData['category']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenUi.scaleFontSize(18.0),
                                color: Colors.white)),
                        SizedBox(height: screenUi.scaleHeight(10.0)),
                        Text("")
                      ]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              Text(
                "Available NCD Medicines",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildMedicineTable([widget.medicineData],
                    context), // Call medicine table builder
              ), // Call medicine table builder
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineTable(
      List<Map<String, dynamic>> medicineData, BuildContext context) {
    int counter = 1;
    return DataTable(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      columnSpacing: 35,
      columns: [
        DataColumn(
            label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text(
          'Pharmacy Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          'Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          'Distance',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ],
      rows: medicineData.expand<DataRow>((medicine) {
        return medicine['pharmacies'].map<DataRow>((pharmacy) {
          return DataRow(cells: [
            DataCell(Text('${counter++}')),
            DataCell(
              GestureDetector(
                onTap: () {
                  _showConfirmationDialog(
                      context,
                      medicine['medicine_name'],
                      pharmacy['name'],
                      pharmacy['location'],
                      medicine['price'],
                      medicine['category']);
                },
                child: Text(
                  pharmacy['name'].toString(),
                ),
              ),
            ),
            DataCell(Text(
              pharmacy['location'].toString(),
            )),
            DataCell(Text(
              pharmacy['distance'].toString(),
            )),
          ]);
        }).toList();
      }).toList(),
    );
  }

  // Function to show the confirmation dialog
  void _showConfirmationDialog(
      BuildContext context,
      String medicineName,
      String pharmacyName,
      String pharmacyLocation,
      String medicinePrice,
      String medicineCategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add to Cart?'),
          content: Text('Do you want to add $medicineName to your cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addToCart(context, medicineName, pharmacyName,
                    pharmacyLocation, medicinePrice, medicineCategory);
                Navigator.of(context).pop(true);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to add the medicine to cart or orders table
  Future<void> _addToCart(
      BuildContext context,
      String medicineName,
      String pharmacyName,
      String pharmacyLocation,
      String medicinePrice,
      String medicineCategory) async {
    // Here you can add the code to add the medicine details to your cart or orders table
    // For example, you can send an API request or update local storage
    final data = {
      'medicineName': medicineName,
      'pharmacyName': pharmacyName,
      'pharmacyLocation': pharmacyLocation,
      'medicinePrice': medicinePrice,
      'medicineCategory': medicineCategory
    };

    final result = await Api().postToCartData(route: '/addToCart', data: data);
    final response = jsonDecode(result.body);

    if (response['status']) {
      // Show registration success banner
      Fluttertoast.showToast(
        msg: "Added successfully to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "failed to add to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
