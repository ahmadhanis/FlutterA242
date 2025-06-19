import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/item.dart';
import 'package:unigo/model/user.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems("all");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen"),
        backgroundColor: Colors.amber.shade900,
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
      body: itemList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Try adjusting your search or check back later.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      final item = itemList[index];
                      final imageUrl =
                          "${MyConfig.myurl}unigo/assets/images/items/item-${item.itemId}.png";
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: InkWell(
                          splashColor: Colors.red,
                          onTap: () {
                            showItemDetails(item);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
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

                                // Item details (middle column)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.itemName ?? "No name",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text("Price: RM ${item.itemPrice}"),
                                      Text("Qty: ${item.itemQty}"),
                                      Text("Delivery: ${item.itemDelivery}"),
                                      Text(
                                          "Uni: ${(item.userUniversity ?? "N/A").toUpperCase()}"),
                                      Text(
                                          "Date: ${formatDate(item.itemDate)}"),
                                    ],
                                  ),
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
                      //build the list for textbutton with scroll
                      if ((curpage - 1) == index) {
                        //set current page number active
                        color = Colors.red;
                      } else {
                        color = Colors.black;
                      }
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
            ),
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
        backgroundColor: Colors.amber.shade900,
        child: const Icon(Icons.add),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  void loadItems(String s) {
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
            print(t.itemPrice.toString());
          });
          numofpage = int.parse(data['numofpage'].toString());
          numofresult = int.parse(data['numberofresult'].toString());
          setState(() {});
        } else {
          itemList.clear();
          status = "No item found";
          setState(() {});
        }
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
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName ?? "No Name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                            child: Icon(Icons.broken_image, size: 60)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildIconRow(Icons.description, "Description",
                      item.itemDesc ?? "No description"),
                  _buildIconRow(
                      Icons.verified, "Status", item.itemStatus ?? "No status"),
                  _buildIconRow(Icons.price_change, "Price",
                      "RM ${item.itemPrice ?? "0"}"),
                  _buildIconRow(Icons.confirmation_number, "Quantity",
                      item.itemQty ?? "0"),
                  _buildIconRow(Icons.local_shipping, "Delivery",
                      item.itemDelivery ?? "N/A"),
                  _buildIconRow(
                      Icons.date_range, "Date", formatDate(item.itemDate)),
                  _buildIconRow(
                      Icons.verified_user, "Name", item.userName ?? "No name"),
                  if (phone.isNotEmpty)
                    _buildIconRow(Icons.phone, "Phone", phone),

                  const SizedBox(height: 20),

                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: phone.isNotEmpty
                            ? () => _launchDialer(phone)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.call),
                      ),
                      IconButton(
                        onPressed: phone.isNotEmpty
                            ? () => _launchWhatsApp(phone)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.chat),
                      ),
                      IconButton(
                        onPressed: () {
                          if (widget.user.userId == item.userId) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text("You cannot send messages to yourself."),
                            ));
                          } else {
                            _showMessagePopup(item.userId.toString(),
                                widget.user.userId.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.email),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
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
                print(searchTerm);
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

  void _showMessagePopup(String receiverId, String senderId) {
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
                    senderId, receiverId, messageController.text.trim());
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
      String senderId, String receiverId, String content) async {
    final response = await http.post(
      Uri.parse("${MyConfig.myurl}unigo/php/send_message.php"),
      body: {
        "sender_id": senderId,
        "receiver_id": receiverId,
        "message_content": content,
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Message sent."),
        ));
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
}
