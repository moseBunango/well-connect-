import 'package:flutter/material.dart';
import 'dart:convert';
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
                   ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset(
                      "lib/assets/loginpageimage.png",
                      height: PhoneSize(context).adaptHeight(250),
                      fit: BoxFit.cover, // Adjust image scaling
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(20),
                  ),
                  Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: PhoneSize(context).adaptFontSize(30),
                      fontWeight: FontWeight.bold, // Attractive color
                    ),
                  ),
                  SizedBox(
                    height:  PhoneSize(context).adaptHeight(20),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'yourEmail@domain.com',
                      filled: true,
                      fillColor: Colors.grey[200], // Subtle background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
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
                    height:  PhoneSize(context).adaptHeight(10),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      filled: true,
                      fillColor: Colors.grey[200], // Subtle background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
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
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.teal, // Consistent color
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
                            "Login",
                          ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(PhoneSize(context).adaptHeight(15.0)),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                  ),
                  SizedBox(height:PhoneSize(context).adaptHeight(20)),
                  Text(
                    "OR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: PhoneSize(context).adaptHeight(16),
                    ),
                  ),
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Login with Google"),
                        style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(PhoneSize(context).adaptHeight(15.0)),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                      ),
                      SizedBox(
                        width: PhoneSize(context).adaptHeight(60),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Login with Facebook"),
                        style:ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(PhoneSize(context).adaptHeight(15.0)),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                      ),
                    ],
                  ),
         
                  SizedBox(
                    height: PhoneSize(context).adaptHeight(30),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Register');
                    },
                    child: Text("Create an account"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff2b4260)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(PhoneSize(context).adaptHeight(15.0)),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PhoneSize(context).adaptHeight(10)),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(Colors.teal),
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
