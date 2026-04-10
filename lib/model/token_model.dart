class TokenModel {
  final String? userId;
  final String? roleId;
  final String? uniqueName;
  final String? communityId;
  final String? firstName;
  final String? lastName;
  final String? cName;
  final String? role;
  final String? nbf;
  final String? exp;
  final String? iat;
  final String? iss;
  final String? aud;

  TokenModel({
    this.userId,
    this.roleId,
    this.uniqueName,
    this.communityId,
    this.firstName,
    this.lastName,
    this.cName,
    this.role,
    this.nbf,
    this.exp,
    this.iat,
    this.iss,
    this.aud,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      userId: json['userid']?.toString(),
      roleId: json['roleid']?.toString(),
      uniqueName: json['unique_name']?.toString(),
      communityId: json['CommunityId']?.toString(),
      firstName: json['FirstName']?.toString(),
      lastName: json['LastName']?.toString(),
      cName: json['CName']?.toString(),
      role: json['role']?.toString(),
      nbf: json['nbf']?.toString(),
      exp: json['exp']?.toString(),
      iat: json['iat']?.toString(),
      iss: json['iss']?.toString(),
      aud: json['aud']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userid': userId,
        'roleid': roleId,
        'unique_name': uniqueName,
        'CommunityId': communityId,
        'FirstName': firstName,
        'LastName': lastName,
        'CName': cName,
        'role': role,
        'nbf': nbf,
        'exp': exp,
        'iat': iat,
        'iss': iss,
        'aud': aud,
      };

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
