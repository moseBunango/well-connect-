import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
class PharmacyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> pharmacyData;

  const PharmacyDetailsPage({Key? key, required this.pharmacyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
        title:
            Text(pharmacyData['name'], style: TextStyle(color: Colors.black)),
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
                    pharmacyData['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Distance: ${pharmacyData['distance']}',
                    style: TextStyle(fontSize: 18),
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
                child: _buildMedicineTable(pharmacyData['medicines'], context),
              ), // Call medicine table builder
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineTable(List<dynamic>? medicines, BuildContext context) {
    if (medicines == null || medicines.isEmpty) {
      return Text('No NCD medicines available'); // Handle no medicine case
    }

    return DataTable(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      columns: const [
        DataColumn(
            label: Text('Medicine Name',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: medicines
          .map((medicine) => _medicineDataRow(medicine, context))
          .toList(),
    );
  }

  // Function to create a DataRow for each medicine
  DataRow _medicineDataRow(
      Map<String, dynamic> medicine, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(GestureDetector(
            onTap: () {
              _showConfirmationDialog(context, medicine);
            },
            child: Text(medicine['medicine_name'] ?? 'Unknown'))),
        DataCell(GestureDetector(
            onTap: () {
              _showConfirmationDialog(context, medicine);
            },
            child: Text(medicine['category'] ?? 'Unknown'))),
        DataCell(GestureDetector(
            onTap: () {
              _showConfirmationDialog(context, medicine);
            },
            child: Text('₹ ${medicine['price'] ?? 'Unknown'}'))),
      ],
    );
  }

  // Function to show the confirmation dialog
  void _showConfirmationDialog(
      BuildContext context, Map<String, dynamic> medicine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add to Cart'),
          content: Text(
              'Do you want to add ${medicine['medicine_name']} to your cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addToCart( medicine);
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
  // Function to add the medicine to cart or orders table
  Future<void> _addToCart(
       Map<String, dynamic> medicine) async {
    // Now you can submit the medicine details to your database
    // Only send the required details to the cart table

    String medicineName = medicine['medicine_name'];
    String pharmacyName = pharmacyData['name'];
    String pharmacyLocation = pharmacyData['location'];
    String MedicinePrice = medicine['price'];
    String medicineCategory = medicine['category'];

    final data = {
      'medicineName': medicineName,
      'pharmacyName': pharmacyName,
      'pharmacyLocation': pharmacyLocation,
      'medicinePrice': MedicinePrice,
      'medicineCategory': medicineCategory,
    };
    final result = await Api().postToCartData(route:'/addToCart', data: data);
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
