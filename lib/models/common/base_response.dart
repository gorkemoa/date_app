import 'api_error.dart';
import 'pagination_meta.dart';

class BaseResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final PaginationMeta? meta;
  final ApiError? error;

  const BaseResponse({
    required this.status,
    required this.message,
    this.data,
    this.meta,
    this.error,
  });

  bool get isSuccess => status;
  bool get hasData => data != null;
  bool get hasPagination => meta != null;

  factory BaseResponse.success({
    required T data,
    String message = 'Success',
    PaginationMeta? meta,
  }) {
    return BaseResponse<T>(
      status: true,
      message: message,
      data: data,
      meta: meta,
    );
  }

  factory BaseResponse.failure({
    required ApiError error,
    String message = 'Bir hata oluştu',
  }) {
    return BaseResponse<T>(
      status: false,
      message: message,
      error: error,
    );
  }

  factory BaseResponse.empty({
    String message = 'Veri bulunamadı',
  }) {
    return BaseResponse<T>(
      status: true,
      message: message,
    );
  }
}
