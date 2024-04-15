import 'package:flutter/material.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';

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

  Future<void> riskAssesment() async {
    final data = {
      'age': ageController.text.toString(),
      'weight': weightController.text.toString(),
      'height': heightController.text.toString(),
      'pressure': bloodPressureController.text.toString(),
      'sugar': bloodSugarController.text.toString(),
    };
    final result =
        await Api().riskAssesment(route: '/riskAssesment', data: data);
    final response = jsonDecode(result.body);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('failed to send: ${response['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Risk Assesment",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.yellow[100],
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
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Age')),
                      SizedBox(
                        width: 40,
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
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('weight')),
                      SizedBox(
                        width: 40,
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
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('height')),
                      SizedBox(
                        width: 40,
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
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('blood pressure')),
                      SizedBox(
                        width: 40,
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
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('blood sugar level')),
                      SizedBox(
                        width: 40,
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
                    height: 20,
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
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      riskAssesment();
                    },
                    child: Text("perform NCD Evaluation"),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.yellow, padding: EdgeInsets.all(15.0)),
                  ),
                ],
              ),
            ),
          )),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
