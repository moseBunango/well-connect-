import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';

import 'package:well_connect_app/components/BottomNavigation.dart';
import 'dart:convert';

import 'package:well_connect_app/components/Ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime? _selectedDate;
  String? _selectedGender;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateProfile() async {
    final data = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'street': _streetController.text,
      'city': _cityController.text,
      'country': _countryController.text,
      'phone_number': _phoneNumberController.text,
      'date_of_birth': _selectedDate != null ? _selectedDate!.toString() : '',
      'gender': _selectedGender ?? '',
    };

    final result = await Api()
        .postProfileUpdateData(route: '/auth/updateProfile', data: data);
    final response = jsonDecode(result.body);
    print(response['status']);
    print(response['data']);
    print(response['error']);
    if (response['status']) {
      // Registration successful
      print('User updated successfully');
      // Navigate to home page
      Navigator.pushNamed(context, '/profileDetailsPage');
      // Show registration success banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('update succesfull:${response['message']}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Registration failed
      print('Failed to update: ${response['message']}');
      // Show error message
      String errorMessage = '';
      int errorNumber = 1;
      response['error'].forEach((field, errors) {
        errors.forEach((error) {
          errorMessage += '$errorNumber. $error \n';
          errorNumber++;
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('update failed:\n $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUi screenUi = ScreenUi(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff2b4260),
        title: Text(
          'Profile update',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Users Address",
                style: TextStyle(
                  fontSize: screenUi.scaleFontSize(20.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        hintText: _selectedDate != null
                            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                            : " Date of Birth",
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                      width: screenUi
                          .scaleHeight(10.0)), // Spacing between TextFields
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      items: <String>['Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'First name',
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      controller:
                          _firstNameController, // Add your controller if needed
                    ),
                  ),
                  SizedBox(
                      width: screenUi
                          .scaleHeight(10.0)), // Spacing between TextFields
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Last name',
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      controller:
                          _lastNameController, // Add your controller if needed
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'street',
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      controller:
                          _streetController, // Add your controller if needed
                    ),
                  ),
                  SizedBox(
                      width: screenUi
                          .scaleHeight(10.0)), // Spacing between TextFields
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'City',
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      controller:
                          _cityController, // Add your controller if needed
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Country',
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
                controller: _countryController,
              ),
              SizedBox(height: screenUi.scaleHeight(10.0)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
                controller: _phoneNumberController,
              ),
              SizedBox(height: screenUi.scaleHeight(20.0)),
              ElevatedButton(
                onPressed: () {
                  _updateProfile();
                },
                child: Text(
                  "Update profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: screenUi
                        .scaleWidth(16.0), // Adjusted font size for better fit
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
