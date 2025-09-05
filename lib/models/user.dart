class UserModel {
  String name;
  String email;
  String epfNumber;
  String userType;
  String company;
  String designation;

  UserModel({
    required this.name,
    required this.email,
    required this.epfNumber,
    required this.userType,
    required this.company,
    required this.designation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name']??'',
      email: json['email']??'',
      epfNumber: json['epf_number']??'',
      userType: json['user_type'??''],
      company: json['company']??'',
      designation: json['designation']??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'epf_number': epfNumber,
      'user_type': userType,
      'company': company,
      'designation': designation,
    };
  }
}
