import 'paciente.dart';

class User {
  final String username;
  final String token;
  final Paciente paciente;

  User({this.username, this.token, this.paciente});

  factory User.fromJSON(Map<String, dynamic> json) {
    return User(
        username: json['username'],
        token: json['token'],
        paciente: Paciente.fromJSON(json['paciente']));
  }
}
