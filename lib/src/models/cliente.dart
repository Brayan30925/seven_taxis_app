import 'dart:convert';

Client clientFromJson(String str) => Client.fromJson(json.decode(str));

String clientToJson(Client data) => json.encode(data.toJson());

class Client {
  String? id;
  String? username;
  String? email;
  String? password;

  Client({
    this.id,
    this.username,
    this.email,
    this.password,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
      id: json["id"] as String?,
      username: json["username"] as String?,
      email: json["email"] as String?,
      password: json["password"] as String?
  );

  Map<String, dynamic> toJson() => {
    "id": id ?? '',
    "username": username ?? '',
    "email": email ?? ''
  };
}
