class Item {
  String? itemId;
  String? userId;
  String? itemName;
  String? itemDesc;
  String? itemStatus;
  String? itemQty;
  String? itemPrice;
  String? itemDelivery;
  String? itemDate;

  Item(
      {this.itemId,
      this.userId,
      this.itemName,
      this.itemDesc,
      this.itemStatus,
      this.itemQty,
      this.itemPrice,
      this.itemDelivery,
      this.itemDate});

  Item.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    userId = json['user_id'];
    itemName = json['item_name'];
    itemDesc = json['item_desc'];
    itemStatus = json['item_status'];
    itemQty = json['item_qty'];
    itemPrice = json['item_price'];
    itemDelivery = json['item_delivery'];
    itemDate = json['item_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['user_id'] = userId;
    data['item_name'] = itemName;
    data['item_desc'] = itemDesc;
    data['item_status'] = itemStatus;
    data['item_qty'] = itemQty;
    data['item_price'] = itemPrice;
    data['item_delivery'] = itemDelivery;
    data['item_date'] = itemDate;
    return data;
  }
}