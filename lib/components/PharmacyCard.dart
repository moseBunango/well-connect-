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
        child: Card(
          color: Colors.yellow[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
              child: Image.network(
                  image, 
                  width: 150,
                   height: 150,
                  fit: BoxFit.cover,
          ),
          ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Distance: $distance',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
