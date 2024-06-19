import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'package:well_connect_app/pages/Maps.dart';
class PharmacyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> pharmacyData;

  const PharmacyDetailsPage({Key? key, required this.pharmacyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2b4260),
        title:
            Text(pharmacyData['name'],style: TextStyle(color: Colors.white),),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children:[ 
                             Text(
                            "Name: ${pharmacyData['name']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: PhoneSize(context).adaptFontSize(18),
                              color: Colors.white,
                            ),
                            ),
                      /*SizedBox(height: PhoneSize(context).adaptHeight(10)),
                      Text(
                        'Distance: ${pharmacyData['distance']}',
                        style: TextStyle(
                          color: Colors.white,fontSize:PhoneSize(context).adaptFontSize(18)
                        ),
                      ),*/
                      TextButton(onPressed: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>Maps(pharmacyLocation: pharmacyData['location']) ),
                          );
                        },
                        child:Text('Click to view in Map',style:TextStyle
                        (color:Colors.white,
                        fontSize: 18,
                        ),),)
                      ]),
                      SizedBox(width: PhoneSize(context).adaptHeight(30)),
                      Column(
                        children:[
                           Text(
                          "Location: ${pharmacyData['location']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,fontSize:PhoneSize(context).adaptFontSize(18)
                          ),
                        ),
                        SizedBox(height: PhoneSize(context).adaptHeight(10)),
                    ]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: PhoneSize(context).adaptHeight(20)),
              Text(
                "Available NCD Medicines",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: PhoneSize(context).adaptHeight(20)),
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
        DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
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
        DataCell(ClipOval(
          child: Image.asset(
            "lib/assets/bpmeds.png", // Placeholder if no image URL
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        )),
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
            child: Text('Tzs ${medicine['price'] ?? 'Unknown'}/='))),
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
