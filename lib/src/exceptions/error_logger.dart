import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:queue_management_system/src/exceptions/app_exceptions.dart';

//for errors outside providers like services
class ErrorLogger {
  void logError(Object error, StackTrace? stackTrace) {
    debugPrint('Error: $error');
    debugPrint('Stack Trace: $stackTrace');
  }

  void logAppException(AppException exception) {
    debugPrint('AppException: $exception');
  }
}

final errorLoggerProvider = Provider<ErrorLogger>((ref) {
  return ErrorLogger();
});
