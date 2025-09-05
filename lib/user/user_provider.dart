import 'package:av_master_mobile/models/user.dart';
import 'package:flutter/cupertino.dart';

class UserProvider extends ChangeNotifier{
  UserModel? userModel;

  UserModel? get user => userModel;

  void setUser(UserModel user){
    userModel = user;
    notifyListeners();
  }

  void clearUser(){
    userModel = null;
    notifyListeners();
  }
}