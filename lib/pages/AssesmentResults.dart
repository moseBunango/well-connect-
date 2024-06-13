import 'package:flutter/material.dart';

class Assesmentresults extends StatefulWidget {
  final Map<String, dynamic> results;
  const Assesmentresults({super.key, required this.results});

  @override
  State<Assesmentresults> createState() => _AssesmentresultsState();
}

class _AssesmentresultsState extends State<Assesmentresults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Risk Assessment Results",
         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xff2b4260), // Teal color
        elevation: 0.0, // Remove shadow),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Risk Assessment Results",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            // Add more fields as needed
            // Display results dynamically
            Text(
              widget.results['response'],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}