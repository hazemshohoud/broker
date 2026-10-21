class ServerException implements Exception {
  const ServerException([this.message = 'حدث خطأ في الخادم']);

  final String message;
}
