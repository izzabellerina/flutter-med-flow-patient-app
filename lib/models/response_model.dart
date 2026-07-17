enum ResponseEnum { success, fail }

/// Wrapper ผลลัพธ์จาก service — ตาม flutter-med-flow-user-app
class ResponseModel<T> {
  final T data;
  final ResponseEnum responseEnum;

  ResponseModel({required this.data, required this.responseEnum});

  bool get isSuccess => responseEnum == ResponseEnum.success;
}
