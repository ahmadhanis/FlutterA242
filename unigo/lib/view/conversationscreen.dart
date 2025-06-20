import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/myconfig.dart';

class ConversationScreen extends StatefulWidget {
  final User user;
  final String partnerId;
  final String partnerName;

  const ConversationScreen({
    super.key,
    required this.user,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<dynamic> messages = [];
  bool isLoading = true;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadConversation();
  }

  Future<void> loadConversation() async {
    setState(() => isLoading = true);
    try {
      var response = await http.post(
        Uri.parse("${MyConfig.myurl}unigo/php/load_conversation.php"),
        body: {
          'user_id': widget.user.userId,
          'partner_id': widget.partnerId,
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          messages = jsonData['messages'];
        } else {
          messages = [];
        }
      }
    } catch (e) {
      debugPrint("Error loading conversation: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> sendMessage() async {
    String content = messageController.text.trim();
    if (content.isEmpty) return;

    try {
      var response = await http.post(
        Uri.parse("${MyConfig.myurl}unigo/php/send_message.php"),
        body: {
          'sender_id': widget.user.userId,
          'receiver_id': widget.partnerId,
          'message_content': content,
        },
      );

      if (response.statusCode == 200) {
        messageController.clear();
        loadConversation();
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(date);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerName),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade900, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index];
                      bool isMe =
                          msg['sender_id'].toString() == widget.user.userId;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.amber.shade100
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg['message'] ?? '',
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(msg['sent_time']),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
