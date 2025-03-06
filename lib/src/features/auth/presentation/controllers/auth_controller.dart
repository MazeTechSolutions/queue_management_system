import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:queue_management_system/src/exceptions/app_exceptions.dart';
import 'package:queue_management_system/src/exceptions/error_logger.dart';
import 'package:queue_management_system/src/features/auth/application/auth_service.dart';
import 'package:queue_management_system/src/features/auth/domain/models/auth_state.dart';

// This provider manages the authentication state throughout the app
// It uses StateNotifierProvider to handle the AuthState object
// AuthState tracks:
// - isAuthenticated: whether a user is currently logged in
// - adminEmail: the email of the currently logged in admin
//
// The auth state is used by the router to:
// - Redirect unauthenticated users to login
// - Prevent authenticated users from accessing login/welcome screens
// - Allow/deny access to protected routes

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthController(authService, ref); // Pass 'ref' here
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref ref; // Declare ref to hold the reference to the provider

  AuthController(this._authService, this.ref) : super(AuthState());

  Future<String?> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      state = AuthState(isAuthenticated: true, adminEmail: email);
      return null; // No error
    } on AppException catch (e) {
      ref.read(errorLoggerProvider).logError(e, StackTrace.current);
      return e.message;
    } catch (e, st) {
      ref.read(errorLoggerProvider).logError(e, st);
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<void> signOut() async {
    if (state.adminEmail != null) {
      // If there is an admin email, update the login status to false
      await _authService.updateLoginStatus(state.adminEmail!, false);
    }
    // After signing out, reset the AuthState to its initial state
    state = AuthState();
  }

  Future<String?> createAdmin(String email, String password) async {
    try {
      await _authService.createAdminWithEmailAndPassword(email, password);
      return null; // Success
    } on EmailAlreadyInUseException catch (e) {
      ref.read(errorLoggerProvider).logError(e, StackTrace.current);
      return e.message;
    } on WeakPasswordException catch (e) {
      ref.read(errorLoggerProvider).logError(e, StackTrace.current);
      return e.message;
    } catch (e, st) {
      ref.read(errorLoggerProvider).logError(e, st);
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<void> deleteAdmin(String id) async {
    await _authService.deleteAdmin(id);
  }

  Future<void> checkAuthStatus() async {
    final adminEmail = await _authService.getLoggedInAdmin();
    if (adminEmail != null) {
      state = AuthState(
        isAuthenticated: true,
        adminEmail: adminEmail,
      );
    } else {
      state = AuthState();
    }
  }
}
