import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:well_connect_app/components/API/Api.dart';

import 'package:well_connect_app/components/Ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingin = false;
  final _formKey = GlobalKey<FormState>(); // Add form key

  Future<void> loginUser() async {
    setState(() {
      _isLoggingin = true;
    });
    if (!_formKey.currentState!.validate()) {
      // Form is not valid, do not proceed with login
      setState(() {
        _isLoggingin = false;
      });
      return;
    }

    final data = {
      'email': emailController.text.toString(),
      'password': passwordController.text.toString()
    };

    // Timer to handle timeout
    var timer = Timer(Duration(seconds: 20), () {
      setState(() {
        _isLoggingin = false;
        _showErrorPage(); // Call function to display error page
      });
    });

    try {
      final result =
          await Api().postLoginData(route: '/auth/login', data: data);
      final response = jsonDecode(result.body);
      timer.cancel(); // Cancel timer if successful response

      if (response['status']) {
        // Login successful
        print('User logged in successfully');

        final token = response['token'];
        // Assuming the token is in the response
        await Api().storeAuthToken(token);
        // Navigate to home page
        Navigator.pushNamed(context, '/HomePage');
        // Show registration success banner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Login failed
        print('Failed to login: ${response['error']}');
        // Show error message
        if (response['error'] != null) {
          // If there are errors, generate error messages
          String errorMessage = '';
          int errorNumber = 1;
          response['error'].forEach((field, errors) {
            errors.forEach((error) {
              errorMessage += '$errorNumber. $error\n';
              errorNumber++;
            });
          });
          // Display error messages in the SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('login failed:\n$errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // If there are no errors, display the message from the response
          String message = response['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('login failed:\n$message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle any other errors
      print('Error during login: $e');
      timer.cancel();
      setState(() {
        _isLoggingin = false;
        _showErrorPage(); // Call function to display error page
      });
    } finally {
      setState(() {
        _isLoggingin = false;
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
          content: Text('Login request timed out. Please try again.'),
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
    ScreenUi screenUi = ScreenUi(context);

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(screenUi.scaleWidth(16.0)),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(screenUi.scaleWidth(10.0)),
                      child: Image.asset(
                        "lib/assets/WC.png",
                        height: screenUi.scaleHeight(60.0),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenUi.scaleHeight(8.0)),
                  Center(
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: screenUi.scaleFontSize(30.0),
                        fontWeight: FontWeight.bold, // Attractive color
                      ),
                    ),
                  ),
                  SizedBox(height: screenUi.scaleHeight(20.0)),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[200], // Subtle background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(0), // Rounded corners
                        borderSide: BorderSide(
                          color: Colors.teal, // Consistent color
                        ),
                      ),
                    ),
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenUi.scaleHeight(10.0)),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.grey[200], // Subtle background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(0), // Rounded corners
                        borderSide: BorderSide(
                          color: Colors.teal, // Consistent color
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color(0xff2b4260), // Consistent color
                        ),
                      ),
                    ),
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenUi.scaleHeight(20.0)),
                  ElevatedButton(
                    onPressed: () {
                      loginUser();
                    },
                    child: _isLoggingin
                        ? CircularProgressIndicator()
                        : Text("Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenUi.scaleFontSize(18.0))),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(screenUi.scaleHeight(12.0)),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      overlayColor:
                          MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                  ),
                 SizedBox(height: screenUi.scaleHeight(10.0)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Register');
                    },
                    child: Text(
                      "I dont have an account? Register",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: screenUi.scaleFontSize(18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
