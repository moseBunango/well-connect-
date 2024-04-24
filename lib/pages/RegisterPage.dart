import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';
import 'dart:convert';

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
    final result =
        await Api().postRegisterData(route: '/auth/register', data: data);
    final response = jsonDecode(result.body);
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
      print('Failed to register: ${response['message']}');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${response['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isRegistering = false;
    });
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
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: PhoneSize(context).adaptFontSize(30),
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2b4260),
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Text(
                    "Simplify your NCD medication ordering process and perform health assessment to analyze your NCD risk",
                    style: TextStyle(
                      fontSize: PhoneSize(context).adaptFontSize(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(30),
                  ),
                  Text("Email"),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'example@email.com',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(
                            PhoneSize(context).adaptHeight(10)),
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
                  Text("Name"),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'joe doe',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
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
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Text("Password"),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '********',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
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
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Text("Confirm Password"),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '********',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
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
                        : Text(
                            "Register",
                          ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(PhoneSize(context).adaptHeight(15.0)),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
                        ),
                      ),
                      overlayColor:
                          MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                  ),
                  SizedBox(height: PhoneSize(context).adaptHeight(20.0)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/LogInPage');
                    },
                    child: Text(
                      "Already have an Account? Login",
                      style: TextStyle(
                        color: Colors.grey[600]
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
