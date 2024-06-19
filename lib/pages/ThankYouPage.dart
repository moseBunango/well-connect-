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
  return shouldLogout ;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff2b4260),
          title: Text("Well-Connect",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),),
        ),
        body:Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                   Center(
                     child: Text(
                          "You'l recieve your order Shortly",
                          style: TextStyle(
                            fontSize: PhoneSize(context).adaptFontSize(20),
                            
                            fontStyle: FontStyle.italic // Attractive color
                          ),
                        ),
                   ),
                      SizedBox(
                      height: PhoneSize(context).adaptHeight(20),
                    ),
                ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset(
                        "lib/assets/congratulations.jpg",
                        height: PhoneSize(context).adaptHeight(250),
                        fit: BoxFit.cover, // Adjust image scaling
                      ),
                    ),
                    SizedBox(
                      height: PhoneSize(context).adaptHeight(20),
                    ),
                    Center(
                      child: Text(
                        "Thank You For choosing Us",
                        style: TextStyle(
                          fontSize: PhoneSize(context).adaptFontSize(20),
                          fontWeight: FontWeight.bold, // Attractive color
                        ),
                      ),
                    ),
                    SizedBox(
                      height: PhoneSize(context).adaptHeight(20),
                    ),
                    Icon(Icons.stars_sharp)
              ],),
          ),
        ),
    );
  }
}