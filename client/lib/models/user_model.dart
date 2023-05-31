class UserModel {
  final String userID;
  final String username;
  final String image;
  final String email;
  final bool isSeller;

  const UserModel({
    required this.userID,
    required this.username,
    required this.image,
    required this.email,
    required this.isSeller
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userID: json["user_id"] as String,
    username: json["username"] as String,
    image: json["image"] as String,
    email: json["email"] as String,
    isSeller: json["is_seller"] as bool
  );
}
