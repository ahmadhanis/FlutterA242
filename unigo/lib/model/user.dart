class User {
  String? userId;
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  String? userUniversity;
  String? userAddress;
  String? userDatereg;

  User(
      {this.userId,
      this.userName,
      this.userEmail,
      this.userPassword,
      this.userPhone,
      this.userUniversity,
      this.userAddress,
      this.userDatereg});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    userPassword = json['user_password'];
    userPhone = json['user_phone'];
    userUniversity = json['user_university'];
    userAddress = json['user_address'];
    userDatereg = json['user_datereg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['user_password'] = userPassword;
    data['user_phone'] = userPhone;
    data['user_university'] = userUniversity;
    data['user_address'] = userAddress;
    data['user_datereg'] = userDatereg;
    return data;
  }
}