import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

class SharedPrefrence {
  final storage = GetStorage();

  void setCard(String card) {
    storage.write("card", card);
  }

  String getCard() {
    return storage.read("card");
  }

  void setLoggedIn(bool status) {
    storage.write("Logged_in", status);
  }

  bool getLoggedIn() {
    return storage.read("Logged_in") != null
        ? storage.read("Logged_in")
        : false;
  }

  void setActivated(bool status) {
    storage.write("Activated", status);
  }

  bool getActivated() {
    return storage.read("Activated") != null
        ? storage.read("Activated")
        : false;
  }

  void setUserId(String id) {
    storage.write("id", id);
  }

  String getUserId() {
    return storage.read("id");
  }

  void setCustomerId(String id) {
    storage.write("id", id);
  }

  String getCustomerId() {
    return storage.read("id");
  }

  void setUsername(String name) {
    storage.write("username", name);
  }

  String getUsername() {
    return storage.read("username");
  }

  void setUserPassword(String name) {
    storage.write("password", name);
  }

  String getUserPassword() {
    return storage.read("password");
  }

  void setUserphone(String phone) {
    storage.write("phone", phone);
  }

  String getUserphone() {
    return storage.read("phone");
  }

  void setUseremail(String email) {
    storage.write("email", email);
  }

  String getUseremail() {
    return storage.read("email");
  }

  void setShopLogo(String logo) {
    storage.write("logo", logo);
  }

  String getShopLogo() {
    return storage.read("logo");
  }

  void setUserEmailVerified(String email_verified) {
    storage.write("email_verified", email_verified);
  }

  String getUserEmailVerified() {
    return storage.read("email_verified");
  }

  void setUserProfilePhoto(String profile_photo) async {
    storage.write("profile_photo", profile_photo);
  }

  String getUserProfilePhoto() {
    String profilePhoto =
        storage.read("profile_photo") ?? "assets/images/ic_profile.png";
    return profilePhoto ??
        "assets/images/ic_profile.png"; // Use default if null
  }

  // String getUserProfilePhoto() {
  //   return storage.read("profile_photo");
  // }

  void setUserProfileDescription(String description) {
    storage.write("profile_description", description);
  }

  String getUserProfileDescription() {
    return storage.read("profile_description") ?? '';
  }

  void setUserYoutubeChannelName(String description) {
    storage.write("youtube_channel_name", description);
  }

  String getUserYoutubeChannelName() {
    return storage.read("youtube_channel_name") ?? '';
  }

  void setUserVerified(String verified) {
    storage.write("verified", verified);
  }

  String getuserVerified() {
    return storage.read("verified") ?? '';
  }

  void setUserStatus(String status) {
    storage.write("status", status);
  }

  String getuserStatus() {
    return storage.read("status") ?? '';
  }

  void setUserTypeId(String roleId) {
    storage.write("userType", roleId);
  }

  String getuserTypeId() {
    return storage.read("userType") ?? '';
  }

  void setUserhasPassword(String hasPassword) {
    storage.write("hasPassword", hasPassword);
  }

  String getUserhasPassword() {
    return storage.read("hasPassword") ?? '';
  }

  void setWalletBalance(String walletBalance) {
    storage.write("wallet_balance", walletBalance);
  }

  String getWalletBalance() {
    return storage.read('wallet_balance');
  }

  void setUserMembershipNo(String membershipNo) {
    storage.write("membership_no", membershipNo);
  }

  String getUserMembershipNo() {
    return storage.read('membership_no');
  }

  void setUserPhone(String phone) {
    storage.write("phone", phone);
  }

  String getUserPhone() {
    return storage.read('phone');
  }

  void setCardActive(String cardActive) {
    storage.write("card_active", cardActive);
  }

  String getCardActive() {
    return storage.read('card_active');
  }

  void setCustomerDeviceID(String device_id) {
    storage.write("device_id", device_id);
  }

  String getCustomerDeviceID() {
    return storage.read('device_id');
  }

  void setPassword(String password) {
    storage.write("password", password);
  }

  // void setPassword(String password) {
  //   storage.write("password", 123);
  // }

  String getPassword() {
    return storage.read('password') ?? "";
  }

  void setCardRenewalDate(String cardRenewalDate) {
    storage.write("cardRenewalDate", cardRenewalDate);
  }

  String getCardRenewalDate() {
    return storage.read("cardRenewalDate");
  }

  void setUserAddress1(String userAdderess1) {
    storage.write("userAdderess1", userAdderess1);
  }

  String getUserAddress1() {
    return storage.read("userAdderess1");
  }

  void setUserAddress2(String userAdderess2) {
    storage.write("userAdderess2", userAdderess2);
  }

  String getUserAddress2() {
    return storage.read("userAdderess1");
  }

  void setPincode(String pincode) {
    storage.write("pincode", pincode);
  }

  String getPincode() {
    return storage.read("pincode");
  }

  //   void setOtptime(String time) {
  //   storage.write("time", time);
  // }

  // String getOtptime() {
  //   return storage.read("time");
  // }

  void setOtpTime(String validtime) {
    storage.write("validtime", validtime);
  }

  String getOtpTime() {
    return storage.read("validtime") ?? "";
  }

  void setFcmToken(String fcmToken) {
    storage.write("fcmToken", fcmToken);
  }

  String getFcmToken() {
    return storage.read("fcmToken");
  }

  String getDeviceID() {
    return storage.read('device_id') ?? 'Not Defained';
  }

  Future<String> generateDeviceID() async {
    String? deviceId = null;
    if (deviceId == null) {
      var uuid = Uuid();
      deviceId = uuid.v4();
      storage.write("device_id", deviceId);
    }
    return deviceId;
  }
}
