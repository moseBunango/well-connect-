import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Maps extends StatefulWidget {
  final String? pharmacyLocation; // Define pharmacyLocation as a parameter
  const Maps({Key? key, this.pharmacyLocation}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  LatLng? currentLocation;
  LatLng? destination;
  bool isLoading = false;
  final double zoom = 15.0; // Initial zoom level
  List<LatLng> routePoints = [];
  double? distanceInMeters;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchDestination(); // Call to get destination on app launch
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (destination != null) {
        _getRoute();
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _fetchDestination() async {
  setState(() {
    isLoading = true; // Set loading indicator
  });

  final String? placeName = widget.pharmacyLocation;

  if (placeName == null) {
    // If pharmacy location not provided, set default destination
    setState(() {
      destination = LatLng(-6.77284, 39.23438);
      isLoading = false; // Clear loading indicator
    });
    if (currentLocation != null) {
      _getRoute();
    }
    return;
  }

  final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$placeName&format=jsonv2");
  final response = await http.get(url);

  setState(() {
    isLoading = false; // Clear loading indicator
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final firstResult = data[0];
      final double latitude = double.parse(firstResult["lat"]);
      final double longitude = double.parse(firstResult["lon"]);
      setState(() {
        destination = LatLng(latitude, longitude);
      });
    } else {
      // If the place is not found, set default destination
      setState(() {
        destination = LatLng(-6.77284, 39.23438);
      });
    }
    if (currentLocation != null) {
      _getRoute();
    }
  } else {
    print("Error fetching destination: ${response.statusCode}");
  }
}

  Future<void> _getRoute() async {
    if (currentLocation == null || destination == null) return;

    final String url = 'http://router.project-osrm.org/route/v1/driving/'
        '${currentLocation!.longitude},${currentLocation!.latitude};'
        '${destination!.longitude},${destination!.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        routePoints = route.map((point) => LatLng(point[1], point[0])).toList();
      });
     // Calculate distance
      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        destination!.latitude,
        destination!.longitude,
      );
      setState(() {
        distanceInMeters = distance;
      });
    }
      else {
      throw Exception('Failed to load route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:Icon(Icons.arrow_back_ios,
        color: Colors.white,),
        title: Text(
          "Map",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff2b4260),
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : (currentLocation == null)
                  ? Center(child: Text('Finding your location...'))
                  : Container(
                      child: FlutterMap(
                        options: MapOptions(
                          center: currentLocation ?? destination,
                          zoom: zoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentLocation!,
                                width: 80.0,
                                height: 80.0,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.blue, // Source marker as blue
                                  size: 40.0,
                                ),
                              ),
                              if (destination != null)
                                Marker(
                                  point: destination!,
                                  width: 80.0,
                                  height: 80.0,
                                  child: Icon(
                                    Icons.pin_drop,
                                    color: Colors.red, // Destination marker as red
                                    size: 40.0,
                                  ),
                                ),
                            ],
                          ),
                          if (routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: routePoints,
                                  strokeWidth: 4.0,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
          if (distanceInMeters != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  'Distance: ${(distanceInMeters! / 1000).toStringAsFixed(2)} km',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}