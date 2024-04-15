import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:well_connect_app/components/PharmacyCard.dart';
import 'package:well_connect_app/pages/PharmacyDetailsPage.dart';
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pharmacyData = [];
  Timer? _autoScrollTimer;
  final ScrollController _scrollController = ScrollController();
  double _itemWidth = 0.0;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  void initState() {
    super.initState();
    fetchPharmacies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemWidth = MediaQuery.of(context).size.width;
    });
    _startAutoScroll();
    // Call the method to fetch pharmacies when the widget initializes
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel(); // Cancel the timer on widget disposal
    super.dispose();
  }

  Future<void> fetchPharmacies() async {
    // Call your API to fetch pharmacies
    try {
      final result = await Api().getPharmacyData(route: '/getPharmacy');
      final response = json.decode(result.body);

      if (response['status']) {
        // Check if 'data' key exists in the response
        if (response.containsKey('data')) {
          // Cast the 'data' to a list of maps (assuming it's an array of objects)
          setState(() {
            pharmacyData = response['data'].cast<Map<String, dynamic>>();
          });
        } else {
          // Handle the case where 'data' is missing
          print('API response is missing the "data" key.');
        }
      } else {
        // Handle error if the request fails
        print('Failed to fetch pharmacies: ${response['message']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _startAutoScroll() {
    int currentIndex = 0; // Track the current index

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (currentIndex < pharmacyData.length - 1) {
        // If not the last item, scroll to the next item
        currentIndex++;
      } else {
        // If the last item, scroll back to the first item
        currentIndex = 0;
      }
      _scrollController.animateTo(
        currentIndex *
            _itemWidth, // Calculate the scroll offset based on item width
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  void searchPharmacy() {
    searchQuery = searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      // If search query is empty, show a message or handle it as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a pharmacy name to search!'),
        ),
      );
      return; // Exit the method
    }
    // Find the pharmacy in the data
    Map<String, dynamic>? searchedPharmacy = pharmacyData.firstWhere(
      (pharmacy) => pharmacy['name'].toLowerCase() == searchQuery.toLowerCase(),
      orElse: () => {},
    );
    // ignore: unnecessary_null_comparison
    if (searchedPharmacy != null && searchedPharmacy.isNotEmpty) {
      // If pharmacy found, navigate to its details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PharmacyDetailsPage(pharmacyData: searchedPharmacy),
        ),
      );
    } else {
      // If pharmacy not found, show a message or handle it as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pharmacy not found!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              color: Colors.yellow[100],
              padding: EdgeInsets.all(20.0),
              width: 500,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Text(
                      "Welcome to",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Well-Connect",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.black),
                    ),
                  ]),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search NCD pharmacy",
                    suffixIcon: IconButton(
                      onPressed: () {
                        searchPharmacy();
                      },
                      icon: Icon(Icons.search),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "View Pharmacies",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 250, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: pharmacyData.length,
                itemBuilder: (context, index) {
                  final pharmacy = pharmacyData[index];
                  return PharmacyCard(
                    name: pharmacy['name'] ??
                        'Unknown', // Use 'Unknown' if name is null
                    image:
                        pharmacy['image'] ?? 'lib/assets/landingImageTest.png',
                    distance: pharmacy['distance'] != null
                        ? '${pharmacy['distance']} km'
                        : 'Distance unavailable',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PharmacyDetailsPage(pharmacyData: pharmacy),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "Health assesment",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/AssesmentFormPage');
                  },
                  child: Row(children: [
                    Text(
                      "take NCD risk test",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(Icons.arrow_forward_sharp)
                  ])),
            )
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
