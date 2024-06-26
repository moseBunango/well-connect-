import 'package:flutter/material.dart';
import 'package:well_connect_app/components/API/Api.dart';
import 'package:well_connect_app/components/BottomNavigation.dart';
import 'package:well_connect_app/components/Ui.dart';
import 'package:well_connect_app/pages/MedicineListPage.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> medicineData = [];
  List<Map<String, dynamic>> filteredMedicines = [];
  TextEditingController searchMedController = TextEditingController();
  String searchQuery = "";

  void initState() {
    super.initState();
    fetchMedicines();
    // Call the method to fetch pharmacies when the widget initializes
  }

  Future<void> fetchMedicines() async {
    // Call your API to fetch pharmacies
    try {
      final result = await Api().getMedicineData(route: '/getMedicine');
      final response = json.decode(result.body);

      if (response['status']) {
        // Check if 'data' key exists in the response
        if (response.containsKey('data')) {
          // Cast the 'data' to a list of maps (assuming it's an array of objects)
          setState(() {
            medicineData = response['data'].cast<Map<String, dynamic>>();
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

  void searchMedicine() {
    searchQuery = searchMedController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      // If search query is empty, show a message or handle it as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a medicine name to search!'),
        ),
      );
      return; // Exit the method
    }
    // Find the pharmacy in the data
    Map<String, dynamic>? searchedMedicine = medicineData.firstWhere(
      (medicine) =>
          medicine['medicine_name'].toLowerCase() == searchQuery.toLowerCase(),
      orElse: () => {},
    );
    // ignore: unnecessary_null_comparison
    if (searchedMedicine != null && searchedMedicine.isNotEmpty) {
      // If pharmacy found, navigate to its details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MedicineListsPage(medicineData: searchedMedicine),
        ),
      );
    } else {
      // If pharmacy not found, show a message or handle it as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medicine not found!'),
        ),
      );
    }
  }

  void filteredMedicine() {
    // Filter the medicines based on the search query
    List<Map<String, dynamic>> filteredMedicines = medicineData
        .where((medicine) => medicine['medicine_name']
            .toString()
            .toLowerCase()
            .startsWith(searchQuery))
        .toList();

    if (searchQuery.isNotEmpty) {
      // Check if search query is not empty
      if (filteredMedicines.isNotEmpty) {
        // Update the UI with the filtered medicines
        setState(() {
          // Assign the filteredMedicines list to a new list to display below the search field
          this.filteredMedicines = filteredMedicines;
        });
      } else {
        // If no medicines found, clear the displayed list
        setState(() {
          this.filteredMedicines = [];
        });
        // Show a message to indicate no medicines found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No medicines found for "$searchQuery"'),
          ),
        );
      }
    } else {
      // If search query is empty, clear the displayed list
      setState(() {
        this.filteredMedicines = [];
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
        appBar: AppBar(
          title: Text(
            'Search',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xff2b4260),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(screenUi.scaleWidth(16.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             SizedBox(height: screenUi.scaleHeight(10.0)),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value
                            .toLowerCase(); // Update searchQuery with the typed text
                      });
                      filteredMedicine(); // Call filteredMedicine() whenever text changes
                    },
                    controller: searchMedController,
                    decoration: InputDecoration(
                      hintText: "Search NCD medicine ",
                      suffixIcon: IconButton(
                        onPressed: () {
                          searchMedicine();
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
              // Display filtered medicines
              if (filteredMedicines.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = filteredMedicines[index];
                      return ListTile(
                        tileColor: Color(0xff2b4260).withOpacity(0.1),
                        title: Text(
                          medicine['medicine_name'],
                          style: TextStyle(fontSize: screenUi.scaleFontSize(20.0)),
                        ),
                        onTap: () {
                          // Navigate to medicine details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MedicineListsPage(medicineData: medicine),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

             SizedBox(height: screenUi.scaleHeight(20.0)),
              Text(
                "Filte by",
                style: TextStyle(fontSize: screenUi.scaleFontSize(25.0), fontWeight: FontWeight.bold),
              ),
              Text(
                "Categories",
                style: TextStyle(fontSize: screenUi.scaleFontSize(15.0)),
              ),
             SizedBox(height: screenUi.scaleHeight(10.0)),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    _buildCategory('Blood Pressure', Icons.favorite_border),
                    _buildCategory('Diabetes', Icons.favorite_border),
                    _buildCategory('Cancer', Icons.favorite_border),
                    _buildCategory('Obesity', Icons.favorite_border),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }

  Widget _buildCategory(String name, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xff2b4260).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Color(0xff2b4260),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                color: Color(0xff2b4260),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
