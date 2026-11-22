import '../view_models/auth_view_model.dart';

String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    AuthStatus.initializing || AuthStatus.retryRequired =>
      atStart ? null : '/start',
    AuthStatus.signedOut || AuthStatus.authenticating =>
      atPublic ? null : '/login',
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}
