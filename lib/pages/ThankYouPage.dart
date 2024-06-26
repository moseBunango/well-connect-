import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';

class Thankyoupage extends StatefulWidget {
  const Thankyoupage({super.key});

  @override
  State<Thankyoupage> createState() => _ThankyoupageState();
}

class _ThankyoupageState extends State<Thankyoupage> {
  Future<bool> _onWillPop() async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Do you really want to exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    return shouldLogout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: Image.asset(
                  "lib/assets/thank.gif",
                  height: 150,
                ),
              ),
              SizedBox(
                height: PhoneSize(context).adaptHeight(20),
              ),
              Center(
                child: Text(
                  "Thank You for choosing Us",
                  style: TextStyle(
                    fontSize: PhoneSize(context).adaptFontSize(30),
                    fontWeight: FontWeight.bold, // Attractive color
                  ),
                ),
              ),
              SizedBox(
                height: PhoneSize(context).adaptHeight(10),
              ),
              Center(
                child: Text(
                  "You'll receive your order Shortly",
                  style: TextStyle(
                      fontSize: PhoneSize(context).adaptFontSize(16),

                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
