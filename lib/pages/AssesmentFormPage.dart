import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'dart:convert';
import 'dart:async';

import 'package:well_connect_app/pages/AssesmentResults.dart';

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
      // Show registration success banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response['message']}'),
          backgroundColor: Colors.green,
        ),
      );
      print("Hey");
      // Trigger ChatGPT route
      final chatGptResult = await Api().postToChatgpt(route: '/chatgpt/ask');
      print('ChatGPT Result: ${chatGptResult.body}');
      final chatGptResponse = jsonDecode(chatGptResult.body);

      if (chatGptResponse is List && chatGptResponse.isNotEmpty) {
        // Process ChatGPT response
        final chatGptMessage = chatGptResponse[0];
        print('ChatGPT Message: $chatGptMessage');

        // Fetch risk results
        final riskResultsResult =
            await Api().getChatgptData(route: '/getRiskResults');
        print('Risk Results: ${riskResultsResult.body}');
        final riskResultsResponse = jsonDecode(riskResultsResult.body);

        if (riskResultsResponse['status']) {
          // Ensure the data is a map and not a list
          if (riskResultsResponse['data'] is List) {
            final riskResults =
                riskResultsResponse['data'][0] as Map<String, dynamic>;
            final responseMessage = riskResults['response'];
            // Navigate to a new page to display results
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Assesmentresults(results: {'response': responseMessage})),
            );
          } else {
            throw Exception('Unexpected data format');
          }
        } else {
          throw Exception('Failed to fetch risk results');
        }
      } else {
        throw Exception('Unexpected ChatGPT response format');
      }
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
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title with a cleaner font and spacing
              Text(
                "Task to be filled",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto', // or any other desired font family
                ),
              ),
              SizedBox(height: 16.0),

              // Form fields with improved layout
              Form(
                child: Column(
                  children: [
                    // Age field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Age',
                        hintText: 'Enter your age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: ageController,
                    ),
                    SizedBox(height: 16.0),

                    // Weight field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: 'Enter your weight',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: weightController,
                    ),
                    SizedBox(height: 16.0),

                    // Height field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Height (ft)',
                        hintText: 'Enter your height',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: heightController,
                    ),
                    SizedBox(height: 16.0),

                    // Blood pressure field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Blood Pressure (mmHg)',
                        hintText: 'e.g. 60/40',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: bloodPressureController,
                    ),
                    SizedBox(height: 16.0),

                    // Blood sugar field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Blood Sugar Level (mmol/L)',
                        hintText: 'Enter sugar level',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: bloodSugarController,
                    ),
                    SizedBox(height: 16.0),

                    // Description field with a modern multi-line TextForm
                    TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),

              // Risk Assessment button with improved style
              ElevatedButton(
                onPressed: () {
                  riskAssesment();
                },
                child: _isLoggingin
                    ? CircularProgressIndicator()
                    : Text(
                        "Perform Risk Assesment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: PhoneSize(context).adaptFontSize(20),
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(
                      0xff2b4260), // Use primary color for better theme integration
                  minimumSize: Size(double.infinity, 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
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
