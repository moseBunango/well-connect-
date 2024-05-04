import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';
import 'dart:async';

class AsssesmentForm extends StatefulWidget {
  const AsssesmentForm({super.key});

  @override
  State<AsssesmentForm> createState() => _AsssesmentFormState();
}

class _AsssesmentFormState extends State<AsssesmentForm> {
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController bloodSugarController = TextEditingController();
  bool _isLoggingin = false;

  Future<void> riskAssesment() async {

    setState(() {
      _isLoggingin = true;
    });
    final data = {
      'age': ageController.text.toString(),
      'weight': weightController.text.toString(),
      'height': heightController.text.toString(),
      'pressure': bloodPressureController.text.toString(),
      'sugar': bloodSugarController.text.toString(),
    };

    var timer = Timer(Duration(seconds: 20), () {
      setState(() {
        _isLoggingin = false;
        _showErrorPage(); // Call function to display error page
      });
    });

    final result =
        await Api().riskAssesment(route: '/riskAssesment', data: data);
    final response = jsonDecode(result.body);
    timer.cancel();
    if (response['status']) {
      // Registration successful
      print('data sent succesfully');
      // Navigate to home page
      Navigator.pushNamed(context, '/HomePage');
      // Show registration success banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response['message']}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Registration failed
      print('Failed to send: ${response['message']}');
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
            content: Text('Assesment failed:\n $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
    }
    setState(() {
        _isLoggingin = false;
      });
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
        title: Text(
          "Risk Assesment",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xff2b4260), // Teal color
        elevation: 0.0, // Remove shadow
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Task to be filled",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: PhoneSize(context).adaptFontSize(20),
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Age',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,))),
                      SizedBox(
                        width: PhoneSize(context).adaptHeight(40),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Age',
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          controller:
                              ageController, // Add your controller if needed
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('weight',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,))),
                      SizedBox(
                        width:PhoneSize(context).adaptHeight(40),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'weight (kg)',
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          controller:
                              weightController, // Add your controller if needed
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('height',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,))),
                      SizedBox(
                        width:PhoneSize(context).adaptHeight(40),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'height (ft)',
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          controller:
                              heightController, // Add your controller if needed
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('blood pressure',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,))),
                      SizedBox(
                        width: PhoneSize(context).adaptHeight(40),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'eg.60/40 (mmHg)',
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          controller:
                              bloodPressureController, // Add your controller if needed
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('blood sugar level',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,))),
                      SizedBox(
                        width: PhoneSize(context).adaptHeight(40),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'sugar (mmol/L)',
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          controller:
                              bloodSugarController, // Add your controller if needed
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(20),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintText: "add description \n (optional)",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      riskAssesment();
                    },
                    child:  _isLoggingin
                        ? CircularProgressIndicator()
                        : Text(
                            "perform Risk Assesment",style: TextStyle(color: Colors.white),
                          ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff2b4260)
                        , minimumSize: Size(double.infinity, 50.0),),
                  ),
                ],
              ),
            ),
          )),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
