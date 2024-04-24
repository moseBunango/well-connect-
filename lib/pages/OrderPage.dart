import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
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
  String? selectedPaymentMethod;


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

    if (selectedPaymentMethod == 'Pay after delivery') {
      await placeOrder();
    } else if (selectedPaymentMethod == 'Pay online before delivery') {
      // Implement payment gateway integration here
      // For example, you can use Flutterwave API for payment processing
      try {
        // Simulate a delay to mimic a payment process
        await Future.delayed(Duration(seconds: 3));
        // After completing the payment, place the order
        await placeOrder();
      } catch (e) {
        print('Error completing payment and placing order: $e');
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2b4260),
        centerTitle: true,
        title: Text(
          'Order',
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
                    children:[ TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/OrderHistoryPage');
                      },
                      child: Text(
                        'view my order History',
                        style: TextStyle(color: Colors.teal),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                    ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff2b4260),
                      padding: EdgeInsets.all(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file,color: Colors.teal,),
                        Text(fileSelected
                            ? fileName
                            : 'Upload prescription'
                            ,style: TextStyle(color: Colors.teal),), // Display file name if selected, otherwise default text
                      ],
                    ),
                  ),
                               ] ),
                ),
                SizedBox(
                  height: PhoneSize(context).adaptHeight(10),
                ),
                cartItems.isEmpty
                    ? Text(
                        'You have not made any orders',
                        style: 
                        TextStyle(fontSize: PhoneSize(context).adaptFontSize(18),fontWeight: FontWeight.bold),):
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
                  height: PhoneSize(context).adaptHeight(10),
                ),
                // Payment options
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Payment Method:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<String>(
                      title: Text('Pay after delivery'),
                      value: 'Pay after delivery',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Pay online before delivery'),
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
                SizedBox(
                  height: PhoneSize(context).adaptHeight(10),
                ),

                // Place order button
                ElevatedButton(
                  onPressed: _completePaymentAndPlaceOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2b4260),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Text(
                    'Comleete payments & place order',
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
