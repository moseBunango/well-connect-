import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';


class CompleetingOrder extends StatefulWidget {
  const CompleetingOrder({super.key});

  @override
  State<CompleetingOrder> createState() => _CompleetingOrderState();
}

class _CompleetingOrderState extends State<CompleetingOrder> {

  String fileName = '';
  String fileFullPath = "";
  bool fileSelected = false;
  List<dynamic> cartItems = [];
  String? selectedPaymentMethod;
  bool _isLoading = false;

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
    // Check if a prescription file is selected
    if (!fileSelected) {
      Fluttertoast.showToast(
        msg: "Please upload a prescription",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return; // Return without placing the order if no prescription is selected
    }
    try {
      final result = await Api().sendOrderToPharmacy(
        route: '/sendOrderToPharmacy',
        imagePath: fileFullPath,
      );
      final response = json.decode(result.body);

      if (response['status']) {
        print("success");
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
      print(response['status']);
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

 
  void _showErrorPage() {
    // You can display a dialog or navigate to a separate error screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('request timed out. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2b4260),
        centerTitle: true,
        title: Text(
          'Order',style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff2b4260),
                            padding: EdgeInsets.all(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_file,
                                color: Colors.teal,
                              ),
                              Text(
                                fileSelected ? fileName : 'Upload prescription',
                                style: TextStyle(color: Colors.teal),
                              ), // Display file name if selected, otherwise default text
                            ],
                          ),
                        ),
                      ]),
                ),
                SizedBox(
                  height: PhoneSize(context).adaptHeight(10),
                ),
                cartItems.isEmpty
                    ? Text(
                        'Currently you do not have any orders any orders',
                        style: TextStyle(
                            fontSize: PhoneSize(context).adaptFontSize(18),
                            fontWeight: FontWeight.bold),
                      )
                    :
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
                                  Text(
                                      'Price: ${cartItems[index]['medicinePrice']}'),
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
                  height: PhoneSize(context).adaptHeight(10),
                ),
                // Button to pick files
                SizedBox(
                  height: PhoneSize(context).adaptHeight(10),
                ),

                // Place order button
                ElevatedButton(
                  onPressed: placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2b4260),
                    padding: EdgeInsets.all(15),
                    minimumSize: Size(
                        double.infinity, 50.0), // Set fixed width and height
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.teal),
                        )
                      : Text(
                          'place order',style: TextStyle(color: Colors.white),
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