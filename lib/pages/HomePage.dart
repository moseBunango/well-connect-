import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:well_connect_app/components/PharmacyCard.dart';
import 'package:well_connect_app/pages/PharmacyDetailsPage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:well_connect_app/components/API/PhoneSize.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pharmacyData = [];
  List<Map<String, dynamic>>displayedPharmacies = [];
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
  void filteredPharmacy(){
  // Filter the pharmacies based on the search query
  List<Map<String, dynamic>> filteredPharmacies = pharmacyData
      .where((pharmacy) =>
          pharmacy['name'].toString().toLowerCase().startsWith(searchQuery))
      .toList();

  if (searchQuery.isNotEmpty) { // Check if search query is not empty
    if (filteredPharmacies.isNotEmpty) {
      // Update the UI with the filtered pharmacies
      setState(() {
        // Assign the filteredPharmacies list to a new list to display below the search field
        displayedPharmacies = filteredPharmacies;
      });
    } else {
      // If no pharmacies found, clear the displayed list
      setState(() {
        displayedPharmacies = [];
      });
      // Show a message to indicate no pharmacies found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pharmacies found for "$searchQuery"'),
        ),
      );
    }
  } else {
    // If search query is empty, clear the displayed list
    setState(() {
      displayedPharmacies = [];
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6.0),
                    bottomRight: Radius.circular(6.0),
                  ),
                  color: Color(0xff2b4260),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20.0),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: PhoneSize(context).adaptHeight(50),
                    ),
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: PhoneSize(context).adaptFontSize(24),
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(
                      height: PhoneSize(context).adaptHeight(10),
                    ),
                    Text(
                      "Well-Connect",
                      style: TextStyle(
                        fontSize: PhoneSize(context).adaptFontSize(30),
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(PhoneSize(context).adaptHeight(20.0)),
                child: TextFormField(
                  onChanged: (value) {
                     setState(() {
                      searchQuery = value.toLowerCase(); // Update searchQuery with the typed text
                    });
                    filteredPharmacy(); // Call filteredPharmacy() whenever text changes
                  },
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
            // Display filtered pharmacies
            if (displayedPharmacies.isNotEmpty)
              Column(
                children: displayedPharmacies.map((pharmacy) {
                  return ListTile(
                    title: Text(pharmacy['name']),
                    onTap: () {
                      // Navigate to pharmacy details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PharmacyDetailsPage(pharmacyData: pharmacy),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

            SizedBox(
              height:PhoneSize(context).adaptHeight(5),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "View Pharmacies",
                style: TextStyle(fontSize: PhoneSize(context).adaptFontSize(16), fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: PhoneSize(context).adaptHeight(20),
            ),
            Container(
              height: PhoneSize(context).adaptHeight(250), // Adjust height as needed
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
                        'http://10.0.2.2:8000/productimage/${pharmacy['image']}',
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
              height: PhoneSize(context).adaptHeight(20),
            ),
            Container(
              padding: EdgeInsets.all(PhoneSize(context).adaptHeight(20)),
              child: Text(
                "Health assesment",
                style: TextStyle(fontSize: PhoneSize(context).adaptFontSize(16), fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(PhoneSize(context).adaptHeight(20.0)),
              child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/AssesmentFormPage');
                  },
                  child: Row(children: [
                    Text(
                      "take NCD risk test",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: PhoneSize(context).adaptFontSize(14),
                      ),
                    ),
                    SizedBox(
                      width: PhoneSize(context).adaptHeight(20),
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