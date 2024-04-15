import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "WeLL-CoNNECT APP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "NCD Meds at your fingertips,your NCD health Solution",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ClipOval(
              child: Image.asset(
                "lib/assets/landingImage.png",
                height: 350,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/LogInPage');
              },
              child: Text(
                "Get Started",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.yellow, padding: EdgeInsets.all(15.0)),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Register');
                },
                child: Text(
                  "Don't have an Account? Register",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ))
          ],
        )),
      ),
    );
  }
}
