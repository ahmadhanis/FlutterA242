import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/item.dart';
import 'package:unigo/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:unigo/myconfig.dart';

class UserItemScreen extends StatefulWidget {
  final User user;
  const UserItemScreen({super.key, required this.user});

  @override
  State<UserItemScreen> createState() => _UserItemScreenState();
}

class _UserItemScreenState extends State<UserItemScreen> {
  List<Item> itemList = <Item>[]; // List of item objects

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Items'),
        backgroundColor: Colors.amber.shade900,
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
                        SizedBox(
                          //height: 80, // same as image height
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  deleteDialog(item);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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

  void loadUserItems() {
    String userid = widget.user.userId.toString();
    http
        .get(Uri.parse(
            "${MyConfig.myurl}/unigo/php/load_items.php?userid=$userid"))
        .then((response) {
      //log(response.body);
      // print(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          itemList.clear();
          data['data'].forEach((myitem) {
            //  print(myitem);
            Item t = Item.fromJson(myitem);
            itemList.add(t);
          });
          setState(() {});
        }
      }
    });
  }

  void deleteDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: Text("Are you sure you want to delete ${item.itemName}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteItem(item);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void deleteItem(Item item) {
    String itemId = item.itemId.toString();
    http.post(
      body: {
        // "userid":"${widget.user.userId}",
        "itemid": itemId,
      },
      Uri.parse("${MyConfig.myurl}/unigo/php/delete_item.php"),
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${item.itemName} deleted successfully.")),
          );
          loadUserItems(); // Refresh the item list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete item.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error deleting item.")),
        );
      }
    });
  }
}
