class ResponseModel {
  bool success;
  int? total;
  dynamic data;
  String? message;
  ResponseModel({required this.success,this.data,this.total,this.message});

  factory ResponseModel.fromJson(dynamic json){
    return ResponseModel(success: json['status'],data: json['data'],total: json['total'],message: json['message'],);
  }
}