import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alla_zogak_vendor/models/response_model.dart';

final dio = Dio(BaseOptions(baseUrl: 'https://yoo2.smart-node.net/api'));

Future<ResponseModel> getActiveOrders() async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/vendor/my-orders?type=current",
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

Future<ResponseModel> getDeleiveredOrders() async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/vendor/my-orders?type=previous",
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

Future<ResponseModel> getOrderDetails(int id) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/get-subOrders/$id",
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

Future<ResponseModel> updateOrder(int id, Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.put(
      "/vendor/update-suborder/$id",
      data: data,
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
