import 'package:flutter/material.dart';

class PharmacyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
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
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(
                        child: Center(
                          child: Image.asset("lib/assets/pharmacyimage.png")
                        ),
                      );
                    },
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
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Distance: $distance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
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
