import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:well_connect_app/components/PharmacyCard.dart';
import 'package:well_connect_app/components/Ui.dart';
import 'package:well_connect_app/pages/PharmacyDetailsPage.dart';
import 'dart:convert';
import 'dart:async';

import 'package:well_connect_app/pages/ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pharmacyData = [];
  List<Map<String, dynamic>> displayedPharmacies = [];
  Timer? _autoScrollTimer;
  final ScrollController _scrollController = ScrollController();
  double _itemWidth = 0.0;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? street;
  String? city;
  String? country;
  String? phoneNumber;
  DateTime? dateOfBirth;
  String? gender;

  void initState() {
    super.initState();
    fetchPharmacies();
    getProfileDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemWidth = MediaQuery.of(context).size.width;
    });
    _startAutoScroll();
    // Call the method to fetch pharmacies when the widget initializes
  }

  Future<void> getProfileDetails() async {
    final result = await Api().getProfileData(route: '/auth/getProfile');
    final response = jsonDecode(result.body);

    setState(() {
      email = response['data']['email'];
      username = response['data']['username'];
      firstName = response['data']['first_name'];
      lastName = response['data']['last_name'];
      street = response['data']['street'];
      city = response['data']['city'];
      country = response['data']['country'];
      phoneNumber = response['data']['phone_number'];
      dateOfBirth = DateTime.parse(response['data']['date_of_birth']);
      gender = response['data']['gender'];
    });
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

  void filteredPharmacy() {
    // Filter the pharmacies based on the search query
    List<Map<String, dynamic>> filteredPharmacies = pharmacyData
        .where((pharmacy) =>
            pharmacy['name'].toString().toLowerCase().startsWith(searchQuery))
        .toList();

    if (searchQuery.isNotEmpty) {
      // Check if search query is not empty
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
    return shouldLogout;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUi screenUi = ScreenUi(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: gender == null
            ? AppBar(
                backgroundColor: Color(0xff2b4260),
                actions: [
                  IconButton(
                    icon: Icon(Icons.warning, color: Colors.red),
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),
                        items: [
                          PopupMenuItem<String>(
                            value: 'reg',
                            child: Text(
                              'Click here! to complete registration',
                              style: TextStyle(
                                  fontSize: screenUi.scaleFontSize(15.0),
                                  color: Colors.red),
                            ),
                          ),
                        ],
                        elevation: 8.0,
                      ).then((value) {
                        if (value == 'reg')
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                      });
                    },
                  ),
                ],
              )
            : AppBar(
                backgroundColor: Color(0xff2b4260),
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18.0),
                    bottomRight: Radius.circular(18.0),
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
                padding:
                    EdgeInsets.symmetric(horizontal: screenUi.scaleWidth(16.0)),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: screenUi.scaleFontSize(25.0),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenUi.scaleHeight(8.0)),
                    Text(
                      "Well-Connect",
                      style: TextStyle(
                        fontSize: screenUi.scaleFontSize(40.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenUi.scaleHeight(16.0)),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenUi.scaleWidth(16.0),
                      vertical: screenUi.scaleWidth(18.0)),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value
                            .toLowerCase(); // Update searchQuery with the typed text
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

              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: screenUi.scaleWidth(16.0)),
                child: Text(
                  "Available Pharmacies",
                  style: TextStyle(
                    fontSize: screenUi.scaleFontSize(20.0),
                  ),
                ),
              ),
              SizedBox(height: screenUi.scaleHeight(5.0)),
              Container(
                height: screenUi.scaleWidth(250.0), // Adjust height as needed
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
                          'http://192.168.93.60:8000/productimage/${pharmacy['image']}',
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

              Container(
                padding: EdgeInsets.all(screenUi.scaleWidth(16.0)),
                child: Text(
                  "Health assesment",
                  style: TextStyle(
                    fontSize: screenUi.scaleFontSize(20.0),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenUi.scaleWidth(16.0)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenUi.scaleWidth(5.0),
                      vertical: screenUi.scaleWidth(5.0)),
                  color: Color(0xff2b4260)
                      .withOpacity(0.1), // Faint gray background
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/AssesmentFormPage');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Ensures the icon is at the right end
                      children: [
                        Text(
                          "take NCD risk test",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenUi.scaleFontSize(18.0),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_sharp,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}
