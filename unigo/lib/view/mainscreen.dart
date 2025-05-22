import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:unigo/model/item.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/myconfig.dart';
import 'package:unigo/view/loginscreen.dart';
import 'package:unigo/view/newitemscreen.dart';
import 'package:unigo/view/registerscreen.dart';
import 'package:http/http.dart' as http;

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
              })
        ],
      ),
      body: Center(
        child: ListView.builder(
            itemCount: itemList.length,
            itemBuilder: (context, index) => Card(
                    child: Column(
                  children: [
                    Text(itemList[index].itemName.toString()),
                    Text(itemList[index].itemDesc.toString()),
                    Text(itemList[index].itemPrice.toString()),
                    Text(itemList[index].itemQty.toString()),
                    Text(itemList[index].itemDelivery.toString()),
                    Text(itemList[index].itemDate.toString())
                  ],
                ))),
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
      //log(response.body);
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
}
