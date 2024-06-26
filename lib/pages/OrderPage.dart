import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';

import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:well_connect_app/components/Ui.dart';
import 'package:well_connect_app/pages/FlutterWavePayment.dart';
import 'package:well_connect_app/pages/ThankYouPage.dart';
import 'package:well_connect_app/pages/user_list_page.dart';

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
      print(response['status']);

      if (response['status']) {
        print("success");
        Fluttertoast.showToast(
          msg: "Order placed successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await moveCartsToOrderHistory();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Thankyoupage()),
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

  void _completePaymentAndPlaceOrder() async {
    if (selectedPaymentMethod == null) {
      Fluttertoast.showToast(
        msg: "Please select a payment method",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Check if a prescription file is selected
    if (!fileSelected) {
      Fluttertoast.showToast(
        msg: "Please upload a prescription",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return; // Return without proceeding if no prescription is selected
    }

    setState(() {
      _isLoading = true; // Show loader when button is pressed
    });

    // Timer to handle timeout
    var timer = Timer(Duration(seconds: 20), () {
      setState(() {
        _isLoading = false;
        _showErrorPage(); // Call function to display error page
      });
    });

    if (selectedPaymentMethod == 'Pay after delivery') {
      await Future.delayed(Duration(seconds: 3));
      await placeOrder();
      timer.cancel();
      setState(() {
        _isLoading = false; // Hide loader after payment and order attempt
      });
    } else if (selectedPaymentMethod == 'Pay online before delivery') {
      // Navigate to the FlutterwavePayment page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlutterwavePayment()),
      );
      timer.cancel();
      setState(() {
        _isLoading = false; // Hide loader after payment and order attempt
      });
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff2b4260),
          centerTitle: true,
          title: Text(
            'Order',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),
                  items: [
                    PopupMenuItem<String>(
                      value: 'Order status',
                      child: Text(
                        'Order status',
                        style: TextStyle(
                          fontSize: screenUi.scaleFontSize(16.0),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Order History',
                      child: Text(
                        'Order history',
                        style: TextStyle(
                          fontSize: screenUi.scaleFontSize(16.0),
                        ),
                      ),
                    ),
                  ],
                  elevation: 8.0,
                ).then((value) {
                  if (value == 'Order status') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserListPage()),
                    );
                  } else if (value == 'Order History') {
                    Navigator.pushNamed(context, '/OrderHistoryPage');
                  }
                });
              },
            ),
          ],
        ),
        body: cartItems.isEmpty
            ? Center(
                child: Text(
                  'You do not have any order',
                  style: TextStyle(
                      fontSize: screenUi.scaleFontSize(18.0),
                      color: Colors.red),
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(screenUi.scaleWidth(16.0)),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            ElevatedButton(
                              onPressed: _pickFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff2b4260),
                                padding: EdgeInsets.symmetric(
                                    vertical: screenUi.scaleWidth(10.0),
                                    horizontal: screenUi.scaleWidth(10.0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_file,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    fileSelected
                                        ? fileName
                                        : 'Upload prescription',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenUi.scaleFontSize(15.0)),
                                  ), // Display file name if selected, otherwise default text
                                ],
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(height: screenUi.scaleHeight(10.0)),
                        // Your order form fields here
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(
                                  cartItems[index]['pharmacyName'],
                                  style: TextStyle(
                                    fontSize: screenUi.scaleFontSize(16.0),
                                    color: Color(0xff2b4260),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteCartItem(index),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: screenUi.scaleHeight(10.0)),
                        // Payment options
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select payment method:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenUi.scaleFontSize(18.0)),
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Pay after delivery',
                                style: TextStyle(
                                  fontSize: screenUi.scaleFontSize(16.0),
                                ),
                              ),
                              value: 'Pay after delivery',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Pay online before delivery',
                                style: TextStyle(
                                  fontSize: screenUi.scaleFontSize(16.0),
                                ),
                              ),
                              value: 'Pay online before delivery',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                            ),
                          ],
                        ),
                        // Button to pick files
                        SizedBox(height: screenUi.scaleHeight(10.0)),
                        // Place order button
                        ElevatedButton(
                          onPressed: _completePaymentAndPlaceOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff2b4260),
                            padding: EdgeInsets.symmetric(
                              vertical: screenUi.scaleHeight(12.0),
                            ), //
                            minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.9,
                              0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.teal),
                                )
                              : Text(
                                  'Complete payments & place order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenUi.scaleWidth(16.0),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}
