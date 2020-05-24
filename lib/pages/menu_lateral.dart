import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pmrapp/services/locator.service.dart';
import 'package:pmrapp/services/storage.service.dart';
import 'package:pmrapp/services/user.service.dart';
import 'package:pmrapp/services/navigation.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/paciente.dart';
import '../services/locator.service.dart';
import '../services/user.service.dart';

class MenuLateral extends StatefulWidget {
  MenuLateral({Key key}) : super(key: key);
  @override
  _MenuLateral createState() => _MenuLateral();
}

class _MenuLateral extends State<MenuLateral> {
  String username = '';
  Paciente paciente;
  File file = File('');
  NetworkImage image = NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/User_icon_2.svg/240px-User_icon_2.svg.png') ;
  _MenuLateral();

  @override
  void initState() { 
    super.initState();
    this.getPaciente();
  }


  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username = prefs.getString('username');
    if (username != null) return username;
    return "";
  }

  getPaciente() async{
    locator<UserService>().getPaciente(await getUserName())
    .then((value){
      if(value.statusCode == 200){
        setState(() {
          paciente = Paciente.fromJSON(json.decode(value.body)); 
          if(paciente.urlImagen != null){
            this.image = NetworkImage(paciente.urlImagen);
          } 
        });
      }else {
        print('Estatus code no deseado');
      }
    });
  }

  Future<List<Face>> getFaces(context) async {
    final faceDetector = FirebaseVision.instance.faceDetector();
    var file = await ImagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70);
    if (file != null) {
      setState(() {
        _showLoading();
        this.file = file.absolute;
      });
      return faceDetector.processImage(FirebaseVisionImage.fromFile(file));
    }
    return List<Face>();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    return new Drawer(
        child: ListView(
      children: <Widget>[
        new UserAccountsDrawerHeader(
          accountName: Text(
            this.paciente != null ? this.paciente.nombres +'\n'+ this.paciente.apellidos: '',
            style: style.copyWith(
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
          accountEmail: Text(
            this.paciente != null ? this.paciente.cesfam.nombre:'',
            style: style.copyWith(color: Colors.black, fontSize: 10),
          ),
          margin: EdgeInsets.only(bottom: 0.0),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: this.image,
                  fit: BoxFit.fitHeight)),
          currentAccountPicture: MaterialButton(
              minWidth: 8,
              child: Icon(Icons.camera_alt),
              onPressed: (){
                print('change');
                getFaces(context).then((onValue) {
                    if(onValue.length == 1) {
                      _getImage(file.path.split('/').last.split('\.')[0]).then((value) async {
                        this.setState(() => this.image = value);
                        Navigator.of(context).pop();
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                       prefs.setString('urlImagen', value.url);
                        locator<UserService>().updatePicturePaciente(value.url)
                        .then((onValue)=> print(onValue));
                      });
                    }else {
                      Navigator.of(context).pop();
                      _neverSatisfied("No se detecto el rosto o mas un rosto");
                    }
                });
              }),
        ),
        Ink(
            child: ListTile(
          leading: Icon(
            Icons.home,
          ),
          title: Text("Home",
              style: style.copyWith(
                  color: Colors.black, fontWeight: FontWeight.normal)),
          onTap: () {
            locator<NavigationService>().navigateTo('home');
          },
        )),
        ListTile(
          leading: Icon(
            Icons.schedule,
          ),
          title: Text("Horas Solicitadas",
              style: style.copyWith(
                  color: Colors.black, fontWeight: FontWeight.normal)),
          onTap: () {
            locator<NavigationService>().navigateTo('solicitudes');
          },
        ),
        Ink(
          color: Colors.red,
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Cerrar Sesión",
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.normal)),
            onTap: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.setString('token', '');
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            },
          ),
        )
      ],
    ));
  }

  Future<void> _neverSatisfied(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Foto'),
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

  Future<void> _showLoading() {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Row(
            children: [
              CircularProgressIndicator(),
              Container(
                  margin: EdgeInsets.only(left: 5), child: Text("Loading")),
            ],
          ),
        );
      },
    );
  }

  Future<NetworkImage> _getImage(String name) async {
    NetworkImage m;
    if (name != '') {
      await FirebaseStorageService.loadImage(file, name).then((downloadUrl) {
        print('dowload '+downloadUrl);
         m = NetworkImage(
          downloadUrl,
         );
      });
       
      return m;
    }
    return this.image;
  }
}
