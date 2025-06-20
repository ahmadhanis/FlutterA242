// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/shared/mydrawer.dart';
import 'package:unigo/view/conversationscreen.dart';

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

  Future<void> _markMessageAsRead(String messageId) async {
    try {
      await http.post(
        Uri.parse("${MyConfig.myurl}unigo/php/mark_read.php"),
        body: {'message_id': messageId},
      );
    } catch (e) {
      debugPrint("Failed to mark message as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => loadMessages(),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messageList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mail_outline,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        "No messages yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your inbox is empty.\nStart a conversation now!",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    var msg = messageList[index];
                    bool isUnread = msg['is_read'] == 0;
                    return ListTile(
                      onLongPress: () {
                        deleteMessageDialog(msg['message_id'].toString());
                      },
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
                      title: Text(
                          "${msg['receiver_name']} with ${msg['sender_name']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['message'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatDate(msg['sent_time']),
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () async {
                        String senderId = msg['sender_id'].toString();
                        String receiverId = msg['receiver_id'].toString();
                        String partnerId = (senderId == widget.user.userId)
                            ? receiverId
                            : senderId;
                        await _markMessageAsRead(msg['message_id'].toString());

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConversationScreen(
                              user: widget.user,
                              partnerId: partnerId,
                              partnerName:
                                  "${msg['receiver_name']} with ${msg['sender_name']}",
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      drawer: MyDrawer(user: widget.user),
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

  void deleteMessageDialog(String messageid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _deleteMessage(messageid);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  _deleteMessage(String messageid) {
    http.post(
      Uri.parse("${MyConfig.myurl}unigo/php/delete_message.php"),
      body: {'message_id': messageid},
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Message deleted successfully.")),
          );
          loadMessages();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete message.")),
          );
        }
      }
    });
  }
}
