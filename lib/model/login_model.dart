class LoginModel {
  String? token;
  String? redirectTo;
  String? userId;
  String? name;
  String? email;
  bool? isFirstTimeLogin;
  List<RoleItem>? roles;

  LoginModel({
    this.token,
    this.redirectTo,
    this.userId,
    this.name,
    this.email,
    this.isFirstTimeLogin,
    this.roles,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token']?.toString(),
      redirectTo: json['redirectTo']?.toString(),
      userId: json['userId']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      isFirstTimeLogin: json['isFirstTimeLogin'] as bool?,
      roles: json['roles'] != null
          ? (json['roles'] as List)
              .map((e) => RoleItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'redirectTo': redirectTo,
        'userId': userId,
        'name': name,
        'email': email,
        'isFirstTimeLogin': isFirstTimeLogin,
        'roles': roles?.map((r) => r.toJson()).toList(),
      };
}

class RoleItem {
  final String? id;
  final String? name;
  final String? status;

  RoleItem({this.id, this.name, this.status});

  factory RoleItem.fromJson(Map<String, dynamic> json) => RoleItem(
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        status: json['status']?.toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'status': status};
}
