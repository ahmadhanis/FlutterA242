// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/item.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/db_helper.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/shared/mydrawer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FavScreen extends StatefulWidget {
  final User user;
  const FavScreen({super.key, required this.user});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  List<Item> favItems = [];
  late double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    loadFav();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: Column(
        children: [
          Expanded(
            child: favItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          "No favorite items found.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Browse items and tap the ❤ icon to add them here.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favItems.length,
                    itemBuilder: (context, index) {
                      final item = favItems[index];
                      final imageUrl =
                          "${MyConfig.myurl}unigo/assets/images/items/item-${item.itemId}.png";
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: InkWell(
                          splashColor: Colors.purple.shade200,
                          onTap: () {
                            showItemDetails(item, context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    imageUrl,
                                    width: screenWidth * 0.2,
                                    height: screenHeight * 0.15,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 80),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.itemName.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.purple.shade600,
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text("Price: RM ${item.itemPrice}"),
                                          const SizedBox(width: 20),
                                          const Text("|"),
                                          const SizedBox(width: 20),
                                          Text("Qty: ${item.itemQty}"),
                                        ],
                                      ),
                                      Text("Delivery: ${item.itemDelivery}"),
                                      Text("Uni: ${(item.userUniversity)}"),
                                      Text(
                                          "Date: ${formatDate(item.itemDate)}"),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    deleteDataDialog(item, context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      drawer: MyDrawer(user: widget.user),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () async {
      //       Directory documentsDirectory =
      //           await getApplicationDocumentsDirectory();
      //       String dbPath = join(documentsDirectory.path, 'item_fav.db');

      //       bool dbExists = await File(dbPath).exists();

      //       if (dbExists) {
      //         await deleteDatabase(dbPath);
      //       } else {}
      //     },
      //     child: const Icon(Icons.add)),
    );
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat("dd/MM/yyyy").format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }

  Future<void> loadFav() async {
    final db = await DBHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query('tbl_items');
    favItems.clear();
    if (result.isNotEmpty) {
      favItems = result.map((json) => Item.fromJson(json)).toList();
    } else {}
    setState(() {});
  }

  void showItemDetails(Item item, BuildContext context) {
    final imageUrl =
        "${MyConfig.myurl}unigo/assets/images/items/item-${item.itemId}.png";
    final phone = "+6${item.userPhone}";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Image Banner
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 60),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
            
                // Item Details Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truncateString(item.itemName ?? "No Name", 15),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildChip(Icons.price_change, "RM ${item.itemPrice}"),
                          _buildChip(
                              Icons.confirmation_number, "Qty: ${item.itemQty}"),
                          _buildChip(
                              Icons.local_shipping, item.itemDelivery ?? "N/A"),
                          _buildChip(Icons.verified, item.itemStatus ?? "N/A"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                          Icons.description, "Description", item.itemDesc ?? "-"),
                      _buildInfoRow(
                          Icons.date_range, "Date", formatDate(item.itemDate)),
                      _buildInfoRow(
                          Icons.verified_user, "Seller", item.userName ?? "-"),
                      _buildInfoRow(
                          Icons.school, "University", item.userUniversity ?? "-"),
                      if (phone.isNotEmpty)
                        _buildInfoRow(Icons.phone, "Phone", phone),
            
                      const SizedBox(height: 8),
            
                      // Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () => _launchDialer(phone),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.teal),
                            onPressed: () => _launchWhatsApp(phone),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.email, color: Colors.deepPurple),
                            onPressed: () {
                              if (widget.user.userId == item.userId) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "You cannot send messages to yourself.")),
                                );
                              } else {
                                _showMessagePopup(
                                  context,
                                  item.userId.toString(),
                                  widget.user.userId.toString(),
                                  item.itemId.toString(),
                                  item.itemName.toString(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessagePopup(BuildContext context, String receiverId,
      String senderId, String itemId, String itemName) {
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Message"),
        content: TextField(
          controller: messageController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: "Enter your message",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.trim().isNotEmpty) {
                _sendMessage(senderId, receiverId,
                    messageController.text.trim(), itemId, itemName, context);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Message cannot be empty."),
                ));
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.purple.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _launchDialer(String phone) async {
    launchUrlString('tel://$phone');
  }

// WhatsApp launcher
  void _launchWhatsApp(String phone) async {
    launchUrlString(
        'https://wa.me/$phone?text=Hello%20I%20am%20interested%20in%20your%20item.');
  }

  Future<void> _sendMessage(String senderId, String receiverId, String content,
      String productId, String productName, BuildContext context) async {
    final response = await http.post(
      Uri.parse("${MyConfig.myurl}unigo/php/send_message.php"),
      body: {
        "sender_id": senderId,
        "receiver_id": receiverId,
        "message_content": content,
        "product_id": productId,
        "product_name": productName,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        showMessageSentPopup(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to send: ${jsonResponse['message']}"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to send message."),
      ));
    }
  }

  void showMessageSentPopup(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        left: MediaQuery.of(context).size.width * 0.2,
        right: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.green.shade600,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(
              child: Text(
                "Message sent",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void deleteDataDialog(Item item, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text(
            "Are you sure you want to remove this item from favorites?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteFavItem(item, context);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void deleteFavItem(Item item, BuildContext context) async {
    final db = await DBHelper.instance.database;

    int result = await db.delete(
      'tbl_items',
      where: 'item_id = ? AND user_id = ?',
      whereArgs: [item.itemId, item.userId],
    );

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from favorites.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      loadFav();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove item.'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }
}
