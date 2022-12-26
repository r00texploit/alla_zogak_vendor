import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alla_zogak_vendor/models/response_model.dart';

final dio = Dio(BaseOptions(baseUrl: 'https://yoo2.smart-node.net/api'));

Future<ResponseModel> getMyProducts(int limit, int offset,
    [String? search]) async {
  try {
    final res = await dio.get("path");
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

Future<ResponseModel> getMyProductsByCategory(int id) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/vendor/my-products-in-category/$id",
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
      return ResponseModel.fromJson(e.response);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> getSingleProduct(int id) async {
  try {
    final res = await dio.get("path");
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

Future<ResponseModel> createProduct(Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/products",
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
        print(e.response?.data);
      }
      return ResponseModel.fromJson(e.response?.data);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> addProductImages(Map<String, List> data, int? id) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/upload-files/$id",
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
        print(e.response?.data);
      }
      return ResponseModel.fromJson(e.response?.data);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> addProductOtpValues(Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/vendor/add-option-value",
      data: data,
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response?.data);
      }
      return ResponseModel.fromJson(e.response?.data);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> updateOtpValues(int id,Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.put(
      "/vendor/update-option-value/$id",
      data: data,
      options: Options(
        headers: {"token": sh.getString("token")},
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.response?.data);
      }
      return ResponseModel.fromJson(e.response?.data);
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> updateProductDetails(int id, Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.put(
      "/vendor/product-update/$id",
      data: data,
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
      return ResponseModel.fromJson({"status": false});
    }
  }
  return ResponseModel(success: false);
}

Future<ResponseModel> updateProductImage(
    int id, Map<String, dynamic> data) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/update-product-image/$id",
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
        print(e.response?.data);
      }
      if (e.response != null) {
        return ResponseModel.fromJson(e.response?.data);
      }
    }
  }
  return ResponseModel(success: false);
}



Future<ResponseModel> changeProductCover(
    int id) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.post(
      "/update-product-image-cover/$id",
      data: {},
      options: Options(
        headers: {
          "token": sh.getString("token"),
          "Content-Type": "application/json"
        },
      ),
    );
    return ResponseModel.fromJson(res.data);
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.message);
        print(e.response?.data);
      }
      if (e.response != null) {
        return ResponseModel.fromJson(e.response?.data);
      }
    }
  }
  return ResponseModel(success: false);
}



Future<ResponseModel> productDetails(
    int id) async {
  try {
    final sh = await SharedPreferences.getInstance();
    final res = await dio.get(
      "/get-products/$id",
      options: Options(
        headers: {
          "token": sh.getString("token"),
          "Content-Type": "application/json"
        },
      ),
    );
    return ResponseModel.fromJson(jsonDecode(res.data.toString()));
  } catch (e) {
    if (e is DioError) {
      if (kDebugMode) {
        print(e.message);
        print(e.response?.data);
      }
      if (e.response != null) {
        return ResponseModel.fromJson(e.response?.data);
      }
    }
  }
  return ResponseModel(success: false);
}
