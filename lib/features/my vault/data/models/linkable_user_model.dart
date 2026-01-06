class LinkableUser {
  final String fullName;
  final String email;
  final String? image;
  final String id;

  LinkableUser({
    required this.fullName,
    required this.email,
    this.image,
    required this.id,
  });

  factory LinkableUser.fromJson(Map<String, dynamic> json) {
    return LinkableUser(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      image: json['image'] as String?,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'image': image,
      'id': id,
    };
  }
}

class LinkableUsersResponse {
  final List<LinkableUser> users;

  LinkableUsersResponse({required this.users});

  factory LinkableUsersResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> usersJson = json['users'] as List<dynamic>;
    final List<LinkableUser> users = usersJson
        .map(
          (dynamic user) => LinkableUser.fromJson(user as Map<String, dynamic>),
        )
        .toList();

    return LinkableUsersResponse(users: users);
  }
}
