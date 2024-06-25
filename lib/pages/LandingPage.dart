import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/PhoneSize.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(height: 5,),
              Text(
                "WELL-CONNECT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: PhoneSize(context).adaptFontSize(35),
                ),
              ),
              SizedBox(
                height: PhoneSize(context).adaptHeight(10),
              ),
              Text(
                "NCD Meds at your fingertips,your NCD health Solution",
                style: TextStyle(
                  fontSize: PhoneSize(context).adaptFontSize(20),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  "lib/assets/landingpageimage.png",
                  height: PhoneSize(context).adaptHeight(400),
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.cover,
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
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: PhoneSize(context).adaptFontSize(20),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2b4260),
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.8,
                    0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              // SizedBox(
              //   height: PhoneSize(context).adaptHeight(10),
              // ),
              // TextButton(
              //     onPressed: () {
              //       Navigator.pushNamed(context, '/Register');
              //     },
              //     child: Text(
              //       "Don't have an Account? Register",
              //         style: TextStyle(
              //           color: Colors.black,
              //     fontSize: PhoneSize(context).adaptFontSize(20),
              //   ),
              //     ))
            ],
          )),
        ),
      ),
    );
  }
}
