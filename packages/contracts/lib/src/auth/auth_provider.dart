class AuthProvider {
  final dynamic Function() model;

  final List<String> identifierFields;
  final String passwordField;

  const AuthProvider({
    required this.model,
    this.identifierFields = const <String>['email'],
    this.passwordField = 'password',
  });
}
