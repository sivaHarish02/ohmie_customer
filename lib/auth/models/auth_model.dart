class UserModel {
  final String id;
  final String name;
  final String mobile;
  final String token;

  const UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id: user['id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      mobile: user['mobile']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'token': token,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      token: token ?? this.token,
    );
  }
}
