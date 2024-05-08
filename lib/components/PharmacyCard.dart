import 'package:flutter/material.dart';

class PharmacyCard extends StatefulWidget {
  final String name;
  final String distance;
  final String image;
  final VoidCallback onTap;

  const PharmacyCard(
      {super.key,
      required this.name,
      required this.distance,
      required this.image,
      required this.onTap});

  @override
  State<PharmacyCard> createState() => _PharmacyCardState();
}

class _PharmacyCardState extends State<PharmacyCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _isLoading = true; // Show loader when card is tapped
          });
          await Future.delayed(Duration(seconds: 2)); // Simulate loading for 2 seconds
          widget.onTap();
          setState(() {
            _isLoading = false; // Hide loader after loading is complete
          });
        },
        child:  Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
             child: Container(
            width: 200, // Adjust the width as needed
            height: 280, // Adjust the height as needed
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  child: Image.network(
                    widget.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(
                        child: Center(
                          child: Image.asset("lib/assets/pharmacy.jpg")
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(), // Show loader
                  ),
                  Positioned.fill(
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
        ),
      ),
              Positioned(
                  bottom: 12.0,
                  left: 12.0,
                  right: 12.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Distance: ${widget.distance}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),)
    );
  }
}
