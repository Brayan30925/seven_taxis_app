class Driver {
  String? id;
  String? username;
  String? email;
  String? password;
  String? plate;
  String? token;
  String? image;

  Driver({
    this.id,
    this.username,
    this.email,
    this.password,
    this.plate,
    this.token,
    this.image
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"] as String?,
    username: json["username"] as String?,
    email: json["email"] as String?,
    password: json["password"] as String?,
    plate: json["plate"] as String?,
    token: json["token"] as String?,
    image: json["image"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id ?? '',
    "username": username ?? '',
    "email": email ?? '',
    "plate": plate ?? '',
    "token": token ?? '',
    "image": image ?? '',

  };
}
