import 'dart:convert' as convert;
import 'dart:async';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enviroment.dart' as environment;

class UserService {

  UserService() ;

  Future<Response> login(Map user) {
    return post(Uri.encodeFull(environment.Api.url + '/login'),
        headers: {'Content-Type': 'application/json'},
        body: convert.utf8.encode(convert.json.encode(user)));
  }

  Future<Response> getPaciente(String run) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    return get(Uri.encodeFull(environment.Api.url+'/api/paciente/byRun?run='+run),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    }
    );
  }

  Future<Response> getListHorasSolicitadas() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    return get(Uri.encodeFull(environment.Api.url + '/api/hora/byPaciente'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        });
  }

  Future<Response> getHorasEspecialistas(String nombre) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    return get(
        Uri.encodeFull(
            environment.Api.url + '/api/hora/byEspecialidad?nombre=' + nombre),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        });
  }

  Future<Response> asignarPaciente(String id, Map comment) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    return post(Uri.encodeFull(environment.Api.url+'/api/hora/toPaciente?id='+id),
    body: convert.utf8.encode(convert.json.encode(comment)),
    headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        });
  }
  
  Future<Response> updatePicturePaciente(String url) async{
    Map body = {'urlImage': url};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    return post(Uri.encodeFull(environment.Api.url+'/api/paciente/updateImage'),
    body: convert.utf8.encode(convert.json.encode(body)),
    headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        }
    );
  }

  Future<Response> updatePictureQRHora(String url, String id) async{
    Map body = {'url': url};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    return post(Uri.encodeFull(environment.Api.url+'/api/hora/updateImage?id='+id),
    body: convert.utf8.encode(convert.json.encode(body)),
    headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        }
    );
  }
}
