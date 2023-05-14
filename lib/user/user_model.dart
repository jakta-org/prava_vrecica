class User {
  int id;
  String email;
  String? username;
  String? firstName;
  String? lastName;
  String? phoneNumber;

  User(this.id, this.email, this.username, this.firstName, this.lastName, this.phoneNumber);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'] as int,
      json['email'] as String,
      json['username'],
      json['first_name'],
      json['last_name'],
      json['phone_number'],
    );
  }
}