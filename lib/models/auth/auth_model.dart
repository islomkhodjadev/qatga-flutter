class AuthToken {
  final String token;

  AuthToken({required this.token});

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(token: json['token']);
  }
}

class User {
  final int id;
  final String username;
  final String? email;

  User({required this.id, required this.username, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}

class Profile {
  final int id;
  final User user;
  final bool isBusiness;
  final String phoneNumber;
  final String? telegram;
  final String? instagram;
  final String? profilePicture;

  Profile({
    required this.id,
    required this.user,
    required this.isBusiness,
    required this.phoneNumber,
    this.telegram,
    this.instagram,
    this.profilePicture,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      user: User.fromJson(json['user']),
      isBusiness: json['is_business'],
      phoneNumber: json['phone_number'],
      telegram: json['telegram'],
      instagram: json['instagram'],
      profilePicture: json['profile_picture'],
    );
  }
}