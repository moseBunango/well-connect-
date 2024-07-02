import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';

import 'package:well_connect_app/components/BottomNavigation.dart';
import 'dart:convert';
import 'dart:async';

import 'package:well_connect_app/components/Ui.dart';
import 'package:well_connect_app/pages/HomePage.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? street;
  String? city;
  String? country;
  String? phoneNumber;
  DateTime? dateOfBirth;
  String? gender;

  void initState() {
    super.initState();
    getProfileDetails();
  }

  Future<void> getProfileDetails() async {
    final result = await Api().getProfileData(route: '/auth/getProfile');
    final response = jsonDecode(result.body);

    setState(() {
      email = response['data']['email'];
      username = response['data']['username'];
      firstName = response['data']['first_name'];
      lastName = response['data']['last_name'];
      street = response['data']['street'];
      city = response['data']['city'];
      country = response['data']['country'];
      phoneNumber = response['data']['phone_number'];
      dateOfBirth = DateTime.parse(response['data']['date_of_birth']);
      gender = response['data']['gender'];
    });
  }

  bool _isLoggingout = false;

  Future<void> logoutUser() async {
    setState(() {
      _isLoggingout = true;
    });

    var timer = Timer(Duration(seconds: 20), () {
      setState(() {
        _isLoggingout = false;
        _showErrorPage();
      });
    });

    final result = await Api().logoutData(route: '/auth/logout');
    final response = jsonDecode(result.body);
    timer.cancel();

    if (response['status']) {
      Navigator.pushNamed(context, '/LandingPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User logged out successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${response['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoggingout = false;
    });
  }

  Future<void> deleteAccount() async {
    final result = await Api().deleteAccount(route: '/auth/deleteAccount');
    final response = jsonDecode(result.body);

    if (response['status']) {
      Navigator.pushNamed(context, '/LandingPage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response['message']}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failure: ${response['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Request timed out. Please try again.'),
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

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteAccount();
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLogoutConfirmationDialog() async {
    ScreenUi screenUi = ScreenUi(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text(
            'Are you sure you want to Logout?',
            style: TextStyle(


              fontSize: screenUi
                  .scaleWidth(16.0), // Adjusted font size for better fit
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: screenUi
                      .scaleWidth(16.0), // Adjusted font size for better fit
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                logoutUser();
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: screenUi
                      .scaleWidth(16.0), // Adjusted font size for better fit
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
     Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => HomePage()),
  );
  return false;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUi screenUi = ScreenUi(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xff2b4260),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                _showDeleteConfirmationDialog();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Contact Information",
                  style: TextStyle(
                    fontSize: screenUi.scaleFontSize(20.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenUi.scaleHeight(10.0)),
                _buildDataRow('Email', email, 'Username', username),
                SizedBox(height: screenUi.scaleHeight(10.0)),
                Text(
                  "User's Address",
                  style: TextStyle(
                    fontSize: screenUi.scaleFontSize(20.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenUi.scaleHeight(10.0)),
                _buildDataRow('First Name', firstName, 'Last Name', lastName),
                SizedBox(height: screenUi.scaleHeight(10.0)),
                _buildDataRow('Street', street, 'City', city),
                SizedBox(height: screenUi.scaleHeight(10.0)),
                _buildDataRow('Country', country, 'Phone Number', phoneNumber),
                SizedBox(height: screenUi.scaleHeight(10.0)),
                _buildDataRow(
                  'Date of Birth',
                  dateOfBirth != null
                      ? '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}'
                      : '',
                  'Gender',
                  gender,
                ),
                SizedBox(height: screenUi.scaleHeight(20.0)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/ProfilePage');
                  },
                  child: Text(
                    "Update my information",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenUi.scaleWidth(
                          16.0), // Adjusted font size for better fit
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2b4260),
                    padding: EdgeInsets.symmetric(
                      vertical: screenUi.scaleHeight(12.0),
                    ), // Adjusted padding
                    minimumSize: Size(
                      screenUi.scaleWidth(screenUi.screenWidth() * 0.8),
                      0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(screenUi.scaleHeight(0)),
                    ), // Adjusted border radius
                  ),
                ),
                SizedBox(height: screenUi.scaleHeight(10.0)),
                ElevatedButton(
                  onPressed: () {
                    _showLogoutConfirmationDialog();
                  },
                  child: _isLoggingout
                      ? CircularProgressIndicator()
                      : Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenUi.scaleWidth(
                                16.0), // Adjusted font size for better fit
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      vertical: screenUi.scaleHeight(12.0),
                    ), // Adjusted padding
                    minimumSize: Size(
                      screenUi.scaleWidth(screenUi.screenWidth() * 0.8),
                      0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(screenUi.scaleHeight(0)),
                    ), // Adjusted border radius
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }

  Widget _buildDataRow(
      String label1, String? value1, String label2, String? value2) {
    return Row(
      children: [
        Expanded(
          child: _buildDisplayField(label1, value1),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildDisplayField(label2, value2),
        ),
      ],
    );
  }

  Widget _buildDisplayField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value ?? '',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        Divider(), // Add a divider for separation
      ],
    );
  }
}
