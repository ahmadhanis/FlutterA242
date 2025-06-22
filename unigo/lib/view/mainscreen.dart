// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, unused_element

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/item.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/db_helper.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/shared/mydrawer.dart';
import 'package:unigo/view/newitemscreen.dart';
import 'package:unigo/view/registerscreen.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Item> itemList = <Item>[]; // List of item objects
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  late double screenWidth, screenHeight;
  var color;
  String status = "Searching...";
  bool isLoading = false;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    loadItems("all");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Place"),
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
              onPressed: () {
                loadItems("all");
              }),
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearchDialog();
              }),
        ],
      ),
      body: RefreshIndicator(
          key: refreshKey,
          color: Colors.amber.shade900,
          onRefresh: () async {
            loadItems("all");
          },
          child: itemList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        status == "Searching..."
                            ? Icons.search
                            : Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Try adjusting your search or check back later.",
                        style: TextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Visibility(
                      visible: isLoading,
                      child: LinearProgressIndicator(
                        value: curpage / numofpage,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.amber.shade900,
                        minHeight: 4,
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Text(
                          "Number of Result: $numofresult of $numofpage page/s",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          final item = itemList[index];
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
                                showItemDetails(item);
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
                                        width: 120,
                                        height: 120,
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
                                          Text(item.itemName ?? "No name",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color:
                                                      Colors.purple.shade600)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Price: RM ${item.itemPrice}"),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              const Text("|"),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text("Qty: ${item.itemQty}"),
                                            ],
                                          ),
                                          Text(
                                              "Delivery: ${item.itemDelivery}"),
                                          Text(
                                              "Uni: ${(item.userUniversity ?? "N/A").toUpperCase()}"),
                                          Text(
                                              "Date: ${formatDate(item.itemDate)}"),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        addtoFavDialog(item);
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
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: numofpage,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          color = (curpage - 1) == index
                              ? Colors.purple.shade600
                              : Colors.black;
                          return TextButton(
                              onPressed: () {
                                curpage = index + 1;
                                loadItems("all");
                              },
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(color: color, fontSize: 18),
                              ));
                        },
                      ),
                    ),
                  ],
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.user.userId == "0") {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please login to add items."),
            ));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewItemScreen(user: widget.user)),
            );
            loadItems("all");
          }
        },
        // backgroundColor: Colors.purple.shade600,
        child: const Icon(Icons.add),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  void loadItems(String s) {
    setState(() {
      isLoading = true; // show loading bar
    });
    http
        .get(Uri.parse(
            "${MyConfig.myurl}/unigo/php/load_items.php?search=$s&pageno=$curpage"))
        .then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          itemList.clear();
          data['data'].forEach((myitem) {
            //  print(myitem);
            Item t = Item.fromJson(myitem);
            itemList.add(t);
          });
          numofpage = int.parse(data['numofpage'].toString());
          numofresult = int.parse(data['numberofresult'].toString());
        } else {
          itemList.clear();
          status = "No item found";
        }
        isLoading = false; // hide loading bar
        setState(() {});
      }
    });
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

  void showItemDetails(Item item) {
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
                      item.itemName ?? "No Name",
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
                    const SizedBox(height: 12),
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

                    const SizedBox(height: 16),

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
    );
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

  Widget _buildChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.purple.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

// Icons + labels
  Widget _buildIconRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
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

// Dialer launcher
  void _launchDialer(String phone) async {
    launchUrlString('tel://$phone');
  }

// WhatsApp launcher
  void _launchWhatsApp(String phone) async {
    launchUrlString(
        'https://wa.me/$phone?text=Hello%20I%20am%20interested%20in%20your%20item.');
  }

  void showSearchDialog() {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search Items"),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: "Enter item name or keyword",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String searchTerm = searchController.text.trim();
                if (searchTerm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a search term."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                loadItems(searchTerm);
                Navigator.of(context).pop();
              },
              child: const Text("Search"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showMessagePopup(
      String receiverId, String senderId, String itemId, String itemName) {
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
                _sendMessage(
                  senderId,
                  receiverId,
                  messageController.text.trim(),
                  itemId,
                  itemName,
                );
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

  Future<void> _sendMessage(
    String senderId,
    String receiverId,
    String content,
    String productId,
    String productName,
  ) async {
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

  void addtoFavDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add to Favorites"),
        content: const Text(
            "Are you sure you want to add this item to your favorites?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              addtoFav(item);
              Navigator.of(context).pop();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> addtoFav(Item item) async {
    final db = await DBHelper.instance.database;

    final existing = await db.query(
      'tbl_items',
      where: 'item_id = ? AND user_id = ?',
      whereArgs: [item.itemId, item.userId],
    );

    if (existing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item already in favorites.")),
      );
      return;
    }

    await db.insert('tbl_items', item.toJson());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item added to favorites.")),
    );
  }
}
