import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'dart:convert';
import 'dart:async';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _isRegistering = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      // Form is not valid, do not proceed with registration
      return;
    }
    setState(() {
      _isRegistering = true;
    });

    final data = {
      'email': emailController.text.toString(),
      'name': nameController.text.toString(),
      'password': passwordController.text.toString(),
      'password_confirmation': passwordConfirmationController.text.toString()
    };

    // Timer to handle timeout
    var timer = Timer(Duration(seconds: 20), () {
      setState(() {
        _isRegistering = false;
        _showErrorPage(); // Call function to display error page
      });
    });

    try {
      final result =
          await Api().postRegisterData(route: '/auth/register', data: data);
      final response = jsonDecode(result.body);
      timer.cancel(); // Cancel timer if successful response

      if (response['status']) {
        final token = response['token'];
        await Api().storeAuthToken(token);
        // Registration successful
        print('User registered successfully');
        // Navigate to home page
        Navigator.pushNamed(context, '/HomePage');
        // Show registration success banner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Registration failed
        print('Failed to register: ${response['error']}');
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
            content: Text('Registration failed:\n $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle any other errors
      print('Error during registration: $e');
      timer.cancel();
      setState(() {
        _isRegistering = false;
        _showErrorPage(); // Call function to display error page
      });
    } finally {
      setState(() {
        _isRegistering = false;
      });
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
          content: Text('Registration request timed out. Please try again.'),
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
                  Center(
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: PhoneSize(context).adaptFontSize(35),
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2b4260),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Text(
                    "Simplify your NCD medication ordering process and perform health assessment to analyze your NCD risk",
                    style: TextStyle(
                      fontSize: PhoneSize(context).adaptFontSize(20),

                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(30),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
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
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
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
                          color: Color(0xff2b4260),
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(20),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password confirmation',
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
                    obscureText: _obscurePassword,
                    controller: passwordConfirmationController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password confirmation is required';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: PhoneSize(context).adaptHeight(20.0)),
                  ElevatedButton(
                    onPressed: () {
                      registerUser();
                    },
                    child: _isRegistering
                        ? CircularProgressIndicator()
                        : Text("Register",
                            style: TextStyle(color: Colors.white,fontSize: 20)),
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
                  SizedBox(height: PhoneSize(context).adaptHeight(10.0)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/LogInPage');
                    },
                    child: Text(
                      "Already have an Account? Login",
                      style: TextStyle(color: Colors.grey[600],fontSize: 18),
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
