class GetUserByMobileModel {
  int? userId;
  bool? isLanguageSelected;
  bool? isFirstTimeLogin;
  bool? isRoleExists;
  bool? isKYCCompleted;

  GetUserByMobileModel({
    this.userId,
    this.isLanguageSelected,
    this.isFirstTimeLogin,
    this.isRoleExists,
    this.isKYCCompleted,
  });

  GetUserByMobileModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] as int?;
    isLanguageSelected = json['isLanguageSelected'] as bool?;
    isFirstTimeLogin = json['isFirstTimeLogin'] as bool?;
    isRoleExists = json['isRoleExists'] as bool?;
    isKYCCompleted = json['isKYCCompleted'] as bool?;
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'isLanguageSelected': isLanguageSelected,
        'isFirstTimeLogin': isFirstTimeLogin,
        'isRoleExists': isRoleExists,
        'isKYCCompleted': isKYCCompleted,
      };
}
