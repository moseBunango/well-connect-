import 'package:flutter/material.dart';
import 'package:well_connect_app/components/Ui.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    ScreenUi screenUi = ScreenUi(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(screenUi.scaleWidth(16.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(screenUi.scaleWidth(10.0)),
                    child: Image.asset(
                      "lib/assets/WC.png",
                      height: screenUi
                          .scaleHeight(60.0), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                    height: screenUi
                        .scaleHeight(10.0)), 
                Text(
                  "WELL-CONNECT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenUi
                        .scaleFontSize(30.0), // Adjusted font size for better fit
                  ),
                ),
                SizedBox(
                  height: screenUi.scaleHeight(10.0),
                ),

                Text(
                  'NCD Meds at your fingertips, your NCD health Solution',
                  style: TextStyle(fontSize: screenUi
                        .scaleFontSize(18.0)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: screenUi.scaleHeight(10.0),
                ),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(screenUi.scaleWidth(20.0)),
                  child: Image.asset(
                    "lib/assets/landingpageimage.png",
                    height: screenUi
                        .scaleWidth(300.0), // Reduced size for a better fit
                    width:   screenUi.scaleWidth(screenUi.screenWidth() * 0.8),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: screenUi.scaleHeight(10.0),
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
                      fontSize: screenUi.scaleWidth(
                          18.0), // Adjusted font size for better fit
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2b4260),
                    padding: EdgeInsets.symmetric(
                      vertical: screenUi.scaleHeight(12.0),
                    ), // Adjusted padding
                    minimumSize: Size(
                      screenUi.scaleWidth(screenUi.screenWidth() * 0.8),
                      0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(screenUi.scaleHeight(0)),
                    ), // Adjusted border radius
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
