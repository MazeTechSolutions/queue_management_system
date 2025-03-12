//base class
sealed class AppException implements Exception {
  AppException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => '$code: $message';
}

String fn(AppException exception) {
  return switch (exception) {
    EmailAlreadyInUseException() => 'Email already in use',
    WeakPasswordException() => 'Password is too weak',
    WrongPasswordException() => 'Wrong password',
    UserNotFoundException() => 'User not found',
    _ => 'An unknown error occurred',
  };
}

class EmailAlreadyInUseException extends AppException {
  EmailAlreadyInUseException()
      : super('email-already-in-use', 'Email already in use');
}

class WeakPasswordException extends AppException {
  WeakPasswordException() : super('weak-password', 'Password is too weak');
}

class WrongPasswordException extends AppException {
  WrongPasswordException() : super('wrong-password', 'Wrong password');
}

class UserNotFoundException extends AppException {
  UserNotFoundException() : super('user-not-found', 'User not found');
}

class UnknownErrorException extends AppException {
  UnknownErrorException(String details) : super('unknown-error', details);
}
