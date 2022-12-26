import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alla_zogak_vendor/models/response_model.dart';

final dio = Dio(BaseOptions(baseUrl: 'https://yoo2.smart-node.net/api'));

Future<ResponseModel> getAllCategories() async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/categories",
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      return ResponseModel.fromJson({"status": false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> getMyCategories() async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/vendor/my-categories",
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      return ResponseModel.fromJson({"status": false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> getSingleCategory(int id) async {
  try {
    final res = await dio.get("path");
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      return ResponseModel.fromJson({"status": false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> getCategoryOptions(int id) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/vendor/get-category-option-values/$id",
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      return ResponseModel.fromJson({"status": false});
    }
  }
  return ResponseModel(success: false);
}
