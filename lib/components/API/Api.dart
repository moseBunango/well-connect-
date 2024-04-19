import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  final String apiUrl = 'http://192.168.91.60:8000/api';

  Future<void> storeAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  // Method to retrieve the API token from secure storage
  Future<String?> retrieveAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  Future<http.Response> postRegisterData(
      {required String route, required Map<String, String> data}) async {
    String fullUrl = apiUrl + route;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _header());
  }

  Future<http.Response> postLoginData(
      {required String route, required Map<String, String> data}) async {
    String fullUrl = apiUrl + route;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _header());
  }

  Future<http.Response> logoutData({
    required String route,
  }) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.post(Uri.parse(fullUrl), headers: headers);
  }

  Future<http.Response> deleteAccount({
    required String route,
  }) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.delete(Uri.parse(fullUrl), headers: headers);
  }

  Future<http.Response> postProfileUpdateData(
      {required String route, required Map<String, String> data}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: headers);
  }

  Future<http.Response> getProfileData({required String route}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.get(Uri.parse(fullUrl), headers: headers);
  }

  Future<http.Response> riskAssesment(
      {required String route, required Map<String, String> data}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: headers);
  }

  Future<http.Response> getPharmacyData({
    required String route,
  }) async {
    String fullUrl = apiUrl + route;
    return await http.get(Uri.parse(fullUrl), headers: _header());
  }

  Future<http.Response> getMedicineData({
    required String route,
  }) async {
    String fullUrl = apiUrl + route;
    return await http.get(Uri.parse(fullUrl), headers: _header());
  }

  Future<http.Response> postToCartData(
      {required String route, required Map<String, String> data}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: headers);
  }

  Future<http.Response> getMyCart({required String route}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.get(Uri.parse(fullUrl), headers: headers);
  }

  Future<http.Response> getMyCartHistory({required String route}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.get(Uri.parse(fullUrl), headers: headers);
  }

  Future<http.Response> deleteOrder({required String route}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.delete(Uri.parse(fullUrl), headers: headers);
  }

  Future<http.Response> deleteOrderHistory({required String route}) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.delete(Uri.parse(fullUrl), headers: headers);
  }

  Future<http.Response> sendOrderToPharmacy(
      {required String route, required String imagePath}) async {
    final token =
        await retrieveAuthToken(); // Assuming you have a function to retrieve token
    final headers = {
      'Content-Type': 'multipart/form-data'
    }; // Set content type for multipart

    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl + route));
    request.headers.addAll(headers);

    var multipartFile =
        await http.MultipartFile.fromPath('prescription', imagePath);
    request.files.add(multipartFile);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return response;
  }
  Future<http.Response> moveCartsToOrderHistory(
      {required String route, }) async {
    final token = await retrieveAuthToken();
    final headers = _header();
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    String fullUrl = apiUrl + route;
    return await http.post(Uri.parse(fullUrl),
     headers: headers);
  }

  _header() =>
      {'Content-type': 'application/json', 'Accept': 'application/json'};
}
