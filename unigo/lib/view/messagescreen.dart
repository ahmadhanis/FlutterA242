import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/shared/mydrawer.dart';

class MessageScreen extends StatefulWidget {
  final User user;
  const MessageScreen({super.key, required this.user});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<dynamic> messageList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    setState(() => isLoading = true);
    try {
      var response = await http.post(
        Uri.parse("${MyConfig.myurl}unigo/php/load_messages.php"),
        body: {'user_id': widget.user.userId},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success' && jsonData['messages'] != null) {
          messageList = jsonData['messages'];
        } else {
          messageList = [];
        }
      } else {
        messageList = [];
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
      messageList = [];
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.amber.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messageList.isEmpty
              ? const Center(
                  child: Text(
                    "No messages found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    var msg = messageList[index];
                    bool isUnread = msg['is_read'] == 0;
                    return ListTile(
                      leading: Stack(
                        children: [
                          const Icon(Icons.mark_email_read_rounded),
                          if (isUnread)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(msg['sender_name'] ?? 'Unknown Sender'),
                      subtitle: Text(
                        msg['message'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatDate(msg['sent_time']),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => _showMessageDetails(msg),
                    );
                  },
                ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  void _replyToMessage(String receiverId, String receiverName) {
    TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to $receiverName'),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Type your message here...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.trim().isEmpty) return;
              var response = await http.post(
                Uri.parse("${MyConfig.myurl}unigo/php/send_message.php"),
                body: {
                  'sender_id': widget.user.userId,
                  'receiver_id': receiverId,
                  'message_content': replyController.text.trim(),
                },
              );
              Navigator.pop(context);
              loadMessages();
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _showMessageDetails(dynamic msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(msg['sender_name'] ?? 'Unknown Sender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Message:"),
            const SizedBox(height: 5),
            Text(
              msg['message'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Sent: ${_formatDate(msg['sent_time'])}"),
          ],
        ),
        actions: [
          if (msg['sender_id'].toString() != widget.user.userId)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _replyToMessage(
                    msg['sender_id'].toString(), msg['sender_name']);
              },
              child: const Text("Reply"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
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
}
