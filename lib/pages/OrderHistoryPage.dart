import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'dart:convert';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<dynamic> cartHistoryItems = [];

   @override
  void initState() {
    super.initState();
    fetchCartHistoryData();
  }
  void deleteCartHistoryItem(int index) async {
    try {
      final result =
          await Api().deleteOrderHistory(route: '/orderHistory/${cartHistoryItems[index]['id']}');
      final response = jsonDecode(result.body);
      if (response['status']) {
        setState(() {
          cartHistoryItems.removeAt(index);
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

  Future<void> fetchCartHistoryData() async {
    // Call your API to fetch pharmacies
    final result = await Api().getMyCartHistory(route: '/getMyCartHistory');
    final response = json.decode(result.body);

    if (response['status']) {
      setState(() {
        cartHistoryItems = response['data'];
      });
    } else {
      throw Exception('Failed to load cartHistory items');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2b4260),
        centerTitle: true,
        title: Text(
          'OrderHistory',style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                cartHistoryItems.isEmpty
                    ? Text(
                        'You have no any orders History',
                        style: TextStyle(fontSize: PhoneSize(context).adaptFontSize(18),fontWeight: FontWeight.bold),):
                // Your order form fields here
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cartHistoryItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(cartHistoryItems[index]['pharmacyName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Medicine: ${cartHistoryItems[index]['medicineName']}'),
                            Text('Price: ${cartHistoryItems[index]['medicinePrice']}'),
                            Text(
                                'Category: ${cartHistoryItems[index]['medicineCategory']}'),
                            Text(
                                'Location: ${cartHistoryItems[index]['pharmacyLocation']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete,color: Colors.red,),
                          onPressed: () => deleteCartHistoryItem(index),
                        ),
                      ),
                    );
                  },
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