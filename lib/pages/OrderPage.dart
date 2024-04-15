import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String fileName = '';
  String fileFullPath = "";
  bool fileSelected = false;
  List<dynamic> cartItems = [];

  void _pickFile() async {
    String? filePath = await FilePicker.platform
        .pickFiles(type: FileType.any)
        .then((result) => result?.files.single.path);

    if (filePath != null) {
      setState(() {
        fileName = filePath.split('/').last;
        fileFullPath = filePath;
        fileSelected = true; // Set fileSelected to true when a file is selected
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  Future<void> fetchCartData() async {
    // Call your API to fetch pharmacies
    final result = await Api().getMyCart(route: '/getMyCart');
    final response = json.decode(result.body);

    if (response['status']) {
      setState(() {
        cartItems = response['data'];
      });
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> deleteCartItem(int index) async {
    try {
      final result =
          await Api().deleteOrder(route: '/orders/${cartItems[index]['id']}');
      final response = jsonDecode(result.body);
      if (response['status']) {
        setState(() {
          cartItems.removeAt(index);
        });
        Fluttertoast.showToast(
          msg: "Order deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception('Failed to delete order');
      }
    } catch (e) {
      print('Error deleting order: $e');
      Fluttertoast.showToast(
        msg: "Failed to delete order",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> placeOrder() async {
    try {
      final result = await Api().sendOrderToPharmacy(
        route: '/sendOrderToPharmacy',
        imagePath: fileFullPath,
      );
      final response = json.decode(result.body);

      if (response['status']) {
        Fluttertoast.showToast(
          msg: "Order placed successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      print('Error placing order: $e');
      Fluttertoast.showToast(
        msg: e
            .toString(), // Consider providing a more user-friendly message based on the exception
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    await moveCartsToOrderHistory();
  }

  Future<void> moveCartsToOrderHistory() async {
    try {
      final result = await Api().moveCartsToOrderHistory(
        route: '/moveCartsToOrderHistory',
      );
      final response = json.decode(result.body);

      if (response['status']) {
         setState(() {
        cartItems.clear();
      });
        Fluttertoast.showToast(
          msg: "added to order history",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      Fluttertoast.showToast(
        msg: e
            .toString(), // Consider providing a more user-friendly message based on the exception
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
        centerTitle: true,
        title: Text(
          'Order',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/OrderHistoryPage');
                  },
                  child: Text(
                    'view my order History',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                // Your order form fields here
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(cartItems[index]['pharmacyName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Medicine: ${cartItems[index]['medicineName']}'),
                            Text('Price: ${cartItems[index]['medicinePrice']}'),
                            Text(
                                'Category: ${cartItems[index]['medicineCategory']}'),
                            Text(
                                'Location: ${cartItems[index]['pharmacyLocation']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteCartItem(index),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                // Button to pick files
                ElevatedButton(
                  onPressed: _pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.all(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file),
                      Text(fileSelected
                          ? fileName
                          : 'Upload prescription'), // Display file name if selected, otherwise default text
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // Place order button
                ElevatedButton(
                  onPressed: placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: EdgeInsets.all(20),
                  ),
                  child: Text(
                    'Place My Order',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
