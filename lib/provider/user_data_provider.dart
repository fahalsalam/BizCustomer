import 'package:flutter/material.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';

import '../store/model/user_model.dart';

class UserData extends ChangeNotifier {
  String _username = '';
  String _userProfilePhoto = 'assets/images/ic_profile.png'; // Default value
  UserModel? userModel;

  String get username => _username;
  String get userProfilePhoto => _userProfilePhoto;

  void setUserName(String newUsername) {
    _username = newUsername;
    SharedPrefrence().setUsername(_username);
    SharedPrefrence().getUsername();
    notifyListeners();
  }

  void setUserProfilePhotoData(String newUserProfilePhoto) {
    if (newUserProfilePhoto != null) {
      // Check for null
      _userProfilePhoto = newUserProfilePhoto.isNotEmpty
          ? newUserProfilePhoto
          : 'assets/images/ic_profile.png';
      SharedPrefrence().setUserProfilePhoto(_userProfilePhoto);
    } else {
      // Handle missing photo data
    }
    notifyListeners();
  }

  void updateUserModel(UserModel newUserModel) {
    userModel = newUserModel;
    notifyListeners();
  }

  // void setUserProfilePhotoData(String newUserProfilePhoto) {
  //   _userProfilePhoto = newUserProfilePhoto.isNotEmpty
  //       ? newUserProfilePhoto
  //       : 'assets/images/ic_profile.png';
  //   SharedPrefrence().setUserProfilePhoto(_userProfilePhoto);
  //   SharedPrefrence().getUserProfilePhoto();
  //   notifyListeners();
  // }

  //   void setUserProfilePhotoData(String newUserProfilePhoto) {
  //   _userProfilePhoto = newUserProfilePhoto;
  //   SharedPrefrence().setUserProfilePhoto(_userProfilePhoto);
  //   SharedPrefrence().getUserProfilePhoto();
  //   notifyListeners();
  // }
}
