import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';

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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset(
                        "lib/assets/WC.png",
                        height: PhoneSize(context).adaptHeight(80),
                        fit: BoxFit.cover, // Adjust image scaling
                      ),
                      
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(5),
                  ),
                  Center(
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: PhoneSize(context).adaptFontSize(35),
                        fontWeight: FontWeight.bold, // Attractive color
                      ),
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(20),
                  ),
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
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(20),
                  ),
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
                  SizedBox(height: PhoneSize(context).adaptHeight(30)),
                  ElevatedButton(
                    onPressed: () {
                      loginUser();
                    },
                    child: _isLoggingin
                        ? CircularProgressIndicator()
                        : Text(
                            "Login",style: TextStyle(color: Colors.white,fontSize: 20)
                          ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(PhoneSize(context).adaptHeight(15.0)),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              PhoneSize(context).adaptHeight(0)),
                        ),
                      ),
                      overlayColor:
                          MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                  ),
                  // SizedBox(height: PhoneSize(context).adaptHeight(10)),
                  // Text(
                  //   "OR",
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: PhoneSize(context).adaptHeight(20),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: PhoneSize(context).adaptHeight(10),
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () {},
                  //       style: ButtonStyle(
                  //         backgroundColor: MaterialStateProperty.all<Color>(
                  //       Color(0xff2b4260)),
                  //         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  //           EdgeInsets.all(
                  //               PhoneSize(context).adaptHeight(15.0)),
                  //         ),
                  //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  //           RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(
                  //                 PhoneSize(context).adaptHeight(10)),
                  //           ),
                  //         ),
                  //         overlayColor: MaterialStateProperty.all<Color>(Colors.teal),
                  //       ),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           ClipOval(
                  //             child: Image.asset(
                  //               'lib/assets/google.jpeg', // Make sure the path is correct and the image is in your assets folder
                  //               height: PhoneSize(context).adaptHeight(25.0),
                  //             ),
                  //           ),
                  //           SizedBox(
                  //             width: PhoneSize(context).adaptHeight(10.0),
                  //           ),
                  //           Text(
                  //             "Login with Google",
                  //             style: TextStyle(color: Colors.white),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: PhoneSize(context).adaptHeight(20),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: () {},
                  //       style: ButtonStyle(
                  //         backgroundColor: MaterialStateProperty.all<Color>(
                  //       Color(0xff2b4260)),
                  //         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  //           EdgeInsets.all(
                  //               PhoneSize(context).adaptHeight(15.0)),
                  //         ),
                  //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  //           RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(
                  //                 PhoneSize(context).adaptHeight(10)),
                  //           ),
                  //         ),
                  //         overlayColor: MaterialStateProperty.all<Color>(Colors.teal),
                  //       ),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           ClipOval(
                  //             child: Image.asset(
                  //               'lib/assets/apple.jpeg', // Make sure the path is correct and the image is in your assets folder
                  //               height: PhoneSize(context).adaptHeight(30.0),
                  //             ),
                  //           ),
                  //           SizedBox(
                  //             width: PhoneSize(context).adaptHeight(10.0),
                  //           ),
                  //           Text(
                  //             "Login with Apple",
                  //             style: TextStyle(color: Colors.white),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: PhoneSize(context).adaptHeight(30),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.pushNamed(context, '/Register');
                  //   },
                  //   child: Text("Create an account",style: TextStyle(color: Colors.white,fontSize: 20)),
                  //   style: ButtonStyle(
                  //     backgroundColor:
                  //         MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                  //     padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  //       EdgeInsets.all(PhoneSize(context).adaptHeight(15.0)),
                  //     ),
                  //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  //       RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(
                  //             PhoneSize(context).adaptHeight(10)),
                  //       ),
                  //     ),
                  //     overlayColor:
                  //         MaterialStateProperty.all<Color>(Colors.teal),
                  //   ),
                  // ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Register');
                    },
                    child: Text(
                      "I dont have an account? Register",
                      style: TextStyle(

                        color: Colors.grey[600],
                        fontSize: 18,
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
