import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class MedicineListsPage extends StatelessWidget {
  final Map<String, dynamic> medicineData;

  const MedicineListsPage({Key? key, required this.medicineData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
        title: Text(medicineData['medicine_name'],
            style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        // Allow scrolling if content overflows
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to left
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Align horizontally
                children: [
                  Text(
                    medicineData['medicine_name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    medicineData['price'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    medicineData['category'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Available NCD Medicines",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildMedicineTable(
                    [medicineData], context), // Call medicine table builder
              ), // Call medicine table builder
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineTable(
      List<Map<String, dynamic>> medicineData, BuildContext context) {
    return DataTable(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      columns: [
        DataColumn(label: Text('Pharmacy Name')),
        DataColumn(label: Text('Location')),
        DataColumn(label: Text('Distance')),
      ],
      rows: medicineData.expand<DataRow>((medicine) {
        return medicine['pharmacies'].map<DataRow>((pharmacy) {
          return DataRow(cells: [
            DataCell(
              GestureDetector(
                onTap: () {
                  _showConfirmationDialog(
                      context,
                      medicine['medicine_name'],
                      pharmacy['name'],
                      pharmacy['location'],
                      pharmacy['distance'],
                      medicine['price'],
                      medicine['category']);
                },
                child: Text(pharmacy['name'].toString()),
              ),
            ),
            DataCell(Text(pharmacy['location'].toString())),
            DataCell(Text(pharmacy['distance'].toString())),
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
      String pharmacyDistance,
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
                _addToCart(
                    context,
                    medicineName,
                    pharmacyName,
                    pharmacyLocation,
                    pharmacyDistance,
                    medicinePrice,
                    medicineCategory);
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
      String pharmacyDistance,
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
  backgroundColor: Colors.green,
  textColor: Colors.white,
);
    }
  }
}
