import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/pages/chart_page.dart';
import 'dart:convert';
import 'dart:async'; // Import async library for Future and Timer

class UserListPage extends StatefulWidget {
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> pharmacies = [];
  List<dynamic> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading with a delay
    Future.delayed(Duration(seconds: 3), () {
      fetchPharmaciesAndMessages();
    });
  }

  Future<void> fetchPharmaciesAndMessages() async {
    final response = await Api().getUserList(route: '/pharmacies'); // Replace with your API endpoint

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pharmacies = data['pharmacies'];
        messages = data['messages'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load pharmacies and messages');
    }
  }

  bool pharmacyHasMessage(int pharmacyId) {
    return messages.any((message) => message['from_id'] == pharmacyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacies'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                int pharmacyId = pharmacies[index]['id'];
                bool hasMessage = pharmacyHasMessage(pharmacyId);
                
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.local_pharmacy),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(pharmacies[index]['name']),
                      ),
                      if (hasMessage)
                        Icon(Icons.check_circle, color: Colors.green), // Display green status icon if there's a message
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          pharmacyId: pharmacyId,
                          userName: pharmacies[index]['name'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
