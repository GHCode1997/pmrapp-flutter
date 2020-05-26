import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pmrapp/model/paciente.dart';
import 'package:pmrapp/model/pmrapp.dart';
import 'package:pmrapp/model/user.dart';
import 'package:pmrapp/providers/database.dart';
import 'package:pmrapp/services/locator.service.dart';
import 'package:pmrapp/services/user.service.dart';
import 'package:pmrapp/services/navigation.service.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final pass = TextEditingController();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    username.dispose();
    pass.dispose();
    super.dispose();
  }
  
  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username = prefs.getString('username');
    if (username != null) {
      return username;
    }
    return "";
  }

  initState() {
    super.initState();
    getUserName().then((value) => this.username.text = value);
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      controller: username,
      validator: (value) {
        if (value.isEmpty) {
          return 'Por favor ingrese su rut con puntos y guion';
        }
        return null;
      },
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: "RUN",
          hintText: "INGRESE EL RUN",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextFormField(
      controller: pass,
      validator: (value) {
        if (value.isEmpty) {
          return 'Por favor ingrese la contraseña';
        }
        return null;
      },
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          labelText: "Contraseña",
          hintText: "Ingrese contraseña",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          _login();
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 79.0,
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.contain,
                    height: 10,
                    width: 200,
                  ),
                ),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      emailField,
                      SizedBox(height: 25.0),
                      passwordField,
                      SizedBox(
                        height: 20.0,
                      ),
                      loginButon,
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final SharedPreferences prefs =
                await SharedPreferences.getInstance();
    if (_formKey.currentState.validate()) {
      try {
      //   final result = await InternetAddress.lookup('pmrappteam.herokuapp.com');
      //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          Map map = {
            'username': '' + username.text,
            'password': '' + pass.text
          };
          var usern = prefs.getString('username');
          var service = locator<UserService>();
          showAlertDialog(context);
          var response = await service.login(map);
          if (response.statusCode == 200) {
            Navigator.pop(context);
            var jsonresponse = convert.json.decode(response.body);
            User user = new User.fromJSON(jsonresponse);
            prefs.setString('token', user.token);
            prefs.setString('username', user.username);
            locator<NavigationService>().navigateTo('home');
            print(prefs.getInt('id').toString());
            if(prefs.getInt('id') == null || usern != username.text){
            locator<UserService>().getPaciente(user.username)
            .then((value){
              if(value.statusCode == 200){
                Paciente pac = Paciente.fromJSON(convert.json.decode(value.body));              
                  locator<PMRDatabase>()
                .insert(PMRApp(name: pac.nombres+' '+pac.apellidos,cesfam: pac.cesfam.nombre))
                .then((value){
                  prefs.setInt('id', value.id);
                });
              }
            });
            }
            username.clear();
            pass.clear();
          } else if (response.statusCode == 403) {
            Navigator.pop(context);
            _neverSatisfied('Error en el ingreso run o contraseña');
          }
      //   }
       } on Exception catch (_) {
         Navigator.pop(context);
         _neverSatisfied('Error en la conexión');
         throw new Exception('not connected');
       }
    }
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5), child: Text("Loading")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _neverSatisfied(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
