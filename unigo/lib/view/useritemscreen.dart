// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unigo/model/item.dart';
import 'package:unigo/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:unigo/shared/animated_route.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/shared/mydrawer.dart';
import 'package:unigo/view/edititemscreen.dart';
import 'package:unigo/view/newitemscreen.dart';

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
    super.initState();
    loadUserItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.userName.toString()} Items'),
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
      body: itemList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No items found.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You haven't listed any items yet.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to item creation screen, e.g., Navigator.push(...)
                      Navigator.push(
                        context,
                        AnimatedRoute.slideFromRight(
                            NewItemScreen(user: widget.user)),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Your First Item"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ],
              ),
            )
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
                    onLongPress: () {
                      updateStatusDialog(item);
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
                          SizedBox(
                            //height: 80, // same as image height
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blue,
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditItemScreen(
                                          user: widget.user,
                                          item: item,
                                        ),
                                      ),
                                    );
                                    loadUserItems(); // Refresh the item list
                                  },
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
                  ),
                );
              },
            ),
      drawer: MyDrawer(user: widget.user),
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
      log(response.body);
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

  void updateStatusDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Status"),
          content: Text(
              "Are you sure you want to update the status of ${item.itemName} to 'Sold'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateStatus(item);
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void updateStatus(Item item) {
    String itemId = item.itemId.toString();
    http.post(
      body: {
        // "userid":"${widget.user.userId}",
        "item_id": itemId,
        "item_status": "sold"
      },
      Uri.parse("${MyConfig.myurl}/unigo/php/update_item_status.php"),
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("${item.itemName} status updated successfully.")),
          );
          loadUserItems(); // Refresh the item list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update item status.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating item status.")),
        );
      }
    });
  }
}
