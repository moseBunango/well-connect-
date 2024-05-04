import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'dart:convert';
import 'dart:async';

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

  // ignore: unused_field
  bool _isLoggingout = false;

  Future<void> logoutUser() async {
    setState(() {
      _isLoggingout = true;
    });

    // Timer to handle timeout
    var timer = Timer(Duration(seconds: 20), () {
      setState(() {
        _isLoggingout = false;
        _showErrorPage(); // Call function to display error page
      });
    });

    final result = await Api().logoutData(route: '/auth/logout');
    final response = jsonDecode(result.body);
    timer.cancel();

    print(response['status']);

    if (response['status']) {
      // Logout successful
      print('User logged out successfully');
      // Navigate to landing page
      Navigator.pushNamed(context, '/LandingPage');
      // Show registration success banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User logged out successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Login failed
      print('Failed to logout: ${response['message']}');
      // Show error message
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
      // Logout successful
      print('Account deleted successfully');
      // Navigate to landing page
      Navigator.pushNamed(context, '/LandingPage');
      // Show registration success banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' ${response['message']}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Login failed
      print('Delete failure: ${response['message']}');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failure: ${response['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorPage() {
    // Replace this with your actual error page logic
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
                // Call the function to delete account
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
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to Logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the function to delete account
                logoutUser();
                Navigator.of(context).pop(true);
              },
              child: Text('logout'),
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
        title: Text(
          'Profile Details',style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff2b4260),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.teal,
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
                "Contact information",
                style: TextStyle(
                  fontSize: PhoneSize(context).adaptFontSize(24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('Email', email),
              SizedBox(height: 10),
              _buildDisplayField('User name', username),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              Text(
                "User's Address",
                style: TextStyle(
                  fontSize: PhoneSize(context).adaptFontSize(24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('First name', firstName),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('Last name', lastName),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('Street', street),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('City', city),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('Country', country),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('Phone number', phoneNumber),
              SizedBox(height: PhoneSize(context).adaptHeight(10)),
              _buildDisplayField(
                'Date of Birth',
                dateOfBirth != null
                    ? '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}'
                    : '',
              ),
              SizedBox(height:PhoneSize(context).adaptHeight(10)),
              _buildDisplayField('Gender', gender),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ProfilePage');
                },
                child: Text("Update my information",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2b4260), padding: EdgeInsets.all(15.0)),
              ),
              SizedBox(
                height: PhoneSize(context).adaptHeight(10),
              ),
              ElevatedButton(
                onPressed: () {
                  _showLogoutConfirmationDialog();
                },
                child: _isLoggingout
                    ? CircularProgressIndicator()
                    : Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, padding: EdgeInsets.all(15.0)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
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
