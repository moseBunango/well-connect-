import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:well_connect_app/components/API/Api.dart';

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

    final result = await Api().postLoginData(route: '/auth/login', data: data);
    final response = jsonDecode(result.body);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${response['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoggingin = false;
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
                  ClipOval(
                    child: Image.asset(
                      "lib/assets/loginImage.jpg",
                      height: 250,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'yourEmail@domain.com',
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
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
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
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
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      loginUser();
                    },
                    child: _isLoggingin
                        ? CircularProgressIndicator()
                        : Text(
                            "Login",
                            style: TextStyle(color: Colors.black),
                          ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.yellow, padding: EdgeInsets.all(15.0)),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "OR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Login with google"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blueGrey,
                            padding: EdgeInsets.all(15.0)),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Login with Facebook"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blueGrey,
                            padding: EdgeInsets.all(15.0)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Register');
                    },
                    child: Text("Create an account"),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey,
                        padding: EdgeInsets.all(15.0)),
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
