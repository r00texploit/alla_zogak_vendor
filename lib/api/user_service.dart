import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alla_zogak_vendor/models/response_model.dart';

final dio = Dio(BaseOptions(baseUrl: 'https://yoo2.smart-node.net/api'));

Future<ResponseModel> login(Map<String, dynamic> data) async {
  try {
    final res = await dio.post("/vendor/login", data: data);
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print({"message": e.message});
        print(e.response);
      }
      return ResponseModel.fromJson({"status": false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> getMyProfile() async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/vendor/get-profile",
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.message);
      }
      return ResponseModel.fromJson(e.response?.data);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> updateProfilePhoto(Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/vendor/update-profile-image",
      data: FormData.fromMap(data),
      options: Options(
        headers: {
          "token": sh.getString("token"),
          "Content-Type": "multipart/form-data"
        },
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.message);
      }
      return ResponseModel.fromJson(e.response);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> updateProfile(Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.put(
      "/vendor/update-profile",
      data: data,
      options: Options(
        headers: {
          "token": sh.getString("token"),
        },
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.message);
      }
      return ResponseModel.fromJson(e.response);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> updatePassword(Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/vendor/update-password",
      data: data,
      options: Options(
        headers: {
          "token": sh.getString("token"),
        },
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.message);
        print(e.response);
      }
      return ResponseModel.fromJson(e.response);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> resetPassword(Map<String, dynamic> data) async {
  try {
    final res = await dio.post("/", data: data);
    return ResponseModel.fromJson(res);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.message);
      }
      return ResponseModel.fromJson(e.response);
    }
  }
  return ResponseModel(success: false);
}


Future<ResponseModel> sendOtp() async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/vendor/get-otp",
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response);
      }
      return ResponseModel.fromJson({'status': false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> verifyOtp(String otp) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.put(
      "/vendor/verify-otp/$otp",
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response);
      }
      return ResponseModel.fromJson({'status': false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> updatePhone(String? otp,Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/vendor/update-phone/$otp",
      data: data,
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response);
      }
      return ResponseModel.fromJson({'status': false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> sendResetOtp(Map<String, dynamic> data) async {
  try {
    final res = await dio.post(
      "/vendor/send-reset-otp",
      data: data,
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response);
      }
      return ResponseModel.fromJson({'status': false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> verifyResetOtp(String otp,Map<String, dynamic> data) async {
  try {
    final res = await dio.put(
      "/vendor/verify/$otp",
      data: data,
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response);
      }
      return ResponseModel.fromJson({'status': false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> resetPasswordWithOtp(String otp,Map<String, dynamic> data) async {
  try {
    final res = await dio.post(
      "/vendor/reset-password/$otp",
      data: data,
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response);
      }
      return ResponseModel.fromJson({'status': false});
    }
  }
  return ResponseModel(success: false);
}