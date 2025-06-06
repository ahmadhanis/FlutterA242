import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/item.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/myconfig.dart';
import 'package:unigo/view/loginscreen.dart';
import 'package:unigo/view/newitemscreen.dart';
import 'package:unigo/view/registerscreen.dart';
import 'package:http/http.dart' as http;
import 'package:unigo/view/useritemscreen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Item> itemList = <Item>[]; // List of item objects

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen"),
        backgroundColor: Colors.amber.shade900,
        actions: [
          IconButton(
              onPressed: () {
                if (widget.user.userId != "0") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserItemScreen(
                              user: widget.user,
                            )),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please login to view your items."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.verified_user)),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login)),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                loadItems();
              }),
        ],
      ),
      body: itemList.isEmpty
          ? const Center(child: Text("No items found."))
          : ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                final item = itemList[index];
                final imageUrl =
                    "${MyConfig.myurl}unigo/assets/images/items/item-${item.itemId}.png";
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 80),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Item details (middle column)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.itemName ?? "No name",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text("Price: RM ${item.itemPrice}"),
                                Text("Qty: ${item.itemQty}"),
                                Text("Delivery: ${item.itemDelivery}"),
                                Text("Date: ${formatDate(item.itemDate)}"),
                              ],
                            ),
                          ),

                          // Trailing full-height section (e.g., for buttons or icons)
                          // Container(
                          //   height: 80, // same as image height
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Icon(Icons.edit, color: Colors.blue),
                          //       Icon(Icons.delete, color: Colors.red),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.user.userId == "0") {
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
            loadItems();
          }
        },
        backgroundColor: Colors.amber.shade900,
        child: const Icon(Icons.add),
      ),
    );
  }

  void loadItems() {
    http
        .get(Uri.parse("${MyConfig.myurl}/unigo/php/load_items.php"))
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
    final phone = "+6${item.userPhone}" ?? "";

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
                      ElevatedButton.icon(
                        onPressed: phone.isNotEmpty
                            ? () => _launchDialer(phone)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.call),
                        label: Text(""),
                      ),
                      ElevatedButton.icon(
                        onPressed: phone.isNotEmpty
                            ? () => _launchWhatsApp(phone)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.chat),
                        label: Text(""),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text("Close"),
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
}
