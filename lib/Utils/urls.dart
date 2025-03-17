class Urls {
  //static const baseUrl = "http://143.110.181.12:7070/api/";
  static const baseUrl = "https://sacrosys.net:6664/api/";
  static const baseUrl1 = "https://sacrosys.net:6664/api/";

  static const deviceInfoPostAPI = "${baseUrl}7263/postDeviceInfo";
  static const login = "${baseUrl}2878/Verification";
  static const categories = "${baseUrl}8363/getVendorClassifications";
  static const stores = "${baseUrl}8363/getApprovedVendorsForFlutterApp";
  static const storesbyCalssification =
      "${baseUrl}8363/getApprovedVendorsbyClassification";
  static const register = "${baseUrl}2878/postCustomerActivation";
  static const sendOtp = "${baseUrl1}5678/sendOtp";
  static const uploadImage = "${baseUrl}9132/ImageUpload";
  static const checkCustomerEligible = "${baseUrl}2878/IsCustomerEligibile";
  static const postRewards = "${baseUrl}7392/PostRewards";
  static const resetPassword = "${baseUrl}2878/resetPassword";
  static const getProfileData = "${baseUrl}2878/getProfileData";
  static const updateProfileData = "${baseUrl}2878/updateProfile";
  static const getPlaceData = "${baseUrl}8363/getPlacesAndTown";
  static const getApprovedVendorsByPlace =
      "${baseUrl}8363/getApprovedVendorsbyPlaces";
  static const postEncashmentRequest = "${baseUrl}7392/postEncashmentRequest";

  // static const postEncashmentRequest= "https://sacrosys.net:6662/api/7392/postEncashmentRequest";
  static const getTransactions =
      "${baseUrl}7392/getLast10CustomerTransactionsByCardNumber";
  static const getFilteredApprovedVendors =
      "${baseUrl}8363/getFilteredApprovedVendorsForFlutter";
  static const getFilteredApprovedSearchByPlaceId =
      "${baseUrl}8363/getFilteredApprovedVendorsForFlutterByPlaceID";
  static const getAppConfig = "${baseUrl}7263/getAppConfig";
  static const getMastersCombo = "${baseUrl}7263/getMastersComboValues";
  static const getMastersFilterCombo = "${baseUrl}7263/getMastersComboFilter";
  static const postAccountDeactivate =
      "${baseUrl}2878/customerAccountDeactivation";
}
