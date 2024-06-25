import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:well_connect_app/components/API/Api.dart';

class ChatPage extends StatefulWidget {
  final int pharmacyId;
  final String userName;

  ChatPage({required this.pharmacyId, required this.userName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _messages = []; // Combine fetched and local messages
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await Api().getMesseges(route: '/pharmacies/${widget.pharmacyId}/messages');
      print(response.statusCode);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        // Check if 'psmessages' and 'usmessages' are not null
        List<dynamic> psMessages = responseData['psmessages'] ?? [];
        List<dynamic> usMessages = responseData['usmessages'] ?? [];

        List<dynamic> combinedMessages = [];
        combinedMessages.addAll(psMessages);
        combinedMessages.addAll(usMessages);

        // Sort combined messages by 'created_at' timestamp
        combinedMessages.sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));

        setState(() {
          _messages = combinedMessages;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Construct the data map
    Map<String, dynamic> data = {
      'body': message,
      'to_id': widget.pharmacyId,
    };

    final response = await Api().sendMessages(route: '/sendmessage', body: data);
    if (response.statusCode == 200) {
      // Update local state immediately after sending message
      setState(() {
        _messages.add({
          'body': message,
          'to_id': widget.pharmacyId,
          'created_at': DateTime.now().toIso8601String(), // Use current time as created_at
        });
        // Sort messages again after adding a new one
        _messages.sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
        _controller.clear();
      });
    } else {
      throw Exception('Failed to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      bool isFromPharmacy = _messages[index]['from_id'] == widget.pharmacyId;
                      String messageTime = DateTime.parse(_messages[index]['created_at']).toLocal().toString(); // Parse and format timestamp

                      return Align(
                        alignment: isFromPharmacy ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: isFromPharmacy ? Colors.grey[300] : Colors.blue[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _messages[index]['body'],
                                style: TextStyle(fontSize: 16.0),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                messageTime,
                                style: TextStyle(color: Colors.grey, fontSize: 12.0),
                              ),
                              Text(
                                isFromPharmacy ? 'from ${widget.userName}' : 'from you',
                                style: TextStyle(color: Colors.grey, fontSize: 12.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: 'Enter message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20.0),
                          ),
                          onSubmitted: (value) {
                            sendMessage(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          sendMessage(_controller.text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
