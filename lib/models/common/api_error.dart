class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  static const ApiError networkError = ApiError(
    code: 'NETWORK_ERROR',
    message: 'İnternet bağlantısı yok',
  );

  static const ApiError unknownError = ApiError(
    code: 'UNKNOWN_ERROR',
    message: 'Beklenmeyen bir hata oluştu',
  );

  static const ApiError notFoundError = ApiError(
    code: 'NOT_FOUND',
    message: 'İçerik bulunamadı',
  );

  @override
  String toString() => 'ApiError(code: $code, message: $message)';
}
