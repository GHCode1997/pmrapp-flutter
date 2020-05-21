import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pmrapp/pages/horaQR.page.dart';
import 'package:pmrapp/model/hora.dart';
import 'package:pmrapp/services/locator.service.dart';
import 'package:pmrapp/services/user.service.dart';
import 'menu_lateral.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(title: title);
}

class _MyHomePageState extends State<MyHomePage> {
  var _horas = new List<Hora>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final TextEditingController _multiLineTextFieldcontroller =
      TextEditingController();
  final String title;
  int index = 0;
  _MyHomePageState({this.title});
  void _getHoras() async {
    _horas = List<Hora>();
     try {
    //   final result = await InternetAddress.lookup('pmrappteam.herokuapp.com');
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        locator<UserService>()
            .getHorasEspecialistas('medico general')
            .then((response) {
          if (response.statusCode == 200) {
            setState(() {
              List<dynamic> list = json.decode(response.body);
              list.forEach((f) => _horas.add(Hora.fromJSON(f)));
            });
          }
        });
    //   }
     } on Exception catch (_) {
       _neverSatisfied("Error conexión", "Hubo un error en la conexión");
       return;
     }
  }

  void initState() {
    super.initState();
    _getHoras();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.title),
        ),
        drawer: MenuLateral(),
        body: ListView.builder(
            itemCount: _horas.length,
            itemBuilder: (context, index) {
              this.index = index;
              return Center(
                  child: Card(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.add_alert),
                      title: Text(_horas[index].fecha),
                      subtitle: Text(_horas[index].hora),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(
                        'Dr. ' +
                            _horas[index].medico.nombres +
                            ' ' +
                            _horas[index].medico.apellidos,
                      ),
                      subtitle: Text(_horas[index].medico.especialidad.nombre),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Text('Solicitar'),
                          onPressed: () async{
                            setState(() {
                              this.index = index;
                            });
                            if(await _askedToLead(this.index)){
                              _showhora(index);
                            }
                            
                            print('solicitar');
                          },
                        )
                      ],
                    )
                  ])));
            }));
  }

  _showhora(int index) async{
    final SharedPreferences prefs =
                await SharedPreferences.getInstance();
    await showDialog(
      context: context,
      builder: (BuildContext context){
        
        return SimpleDialog(children: <Widget>[
          HoraQR(_horas[index],prefs.getString('username'))
        ],);
    });
  }

  Future<bool> _askedToLead(int index) async {
    _multiLineTextFieldcontroller.clear();
    switch (await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('¿Seguro que desea esta hora?'),
            children: <Widget>[
              Container(
                //set padding on all sides
                padding: const EdgeInsets.all(10.0),
                //we create BoxDecoration with the specified border and border radius
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  TextField(
                    controller: _multiLineTextFieldcontroller,
                    maxLines: 7,
                    maxLength: 165,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      labelText: 'Motivo de consulta',
                      prefixText: 'Motivo: ',
                      hintText: 'Ingrese el motivo de la consulta (Opcional)',
                    ),
                  ),
                  SizedBox(height: 10.0),
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.indigo,
                      animationDuration: Duration(milliseconds: 1000),
                      child: Text(
                        'Si',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      }),
                  SizedBox(
                    width: 40,
                  ),
                  MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.red,
                      animationDuration: Duration(milliseconds: 1000),
                      child: Text(
                        'No',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      })
                ],
              )
            ],
          );
        })) {
      case true:
        print('true');
        try {
          final result =
              await InternetAddress.lookup('pmrappteam.herokuapp.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            locator<UserService>().asignarPaciente(
                _horas[index].id.toString(), {
              "comment": " " + _multiLineTextFieldcontroller.text
            }).then((response){
              print(response.body);
              if (response.statusCode == 200 && response.body == '') {
                print('asignada');
                _neverSatisfied('Estado de la Solicitud','Ya tienes una hora asignada en el dia');
              } else if (response.statusCode == 200 && response.body != '') {
                setState(() {
                  _getHoras();
                });
                _showhora(index);
              }
            });
          }
          return true;
        } on Exception catch (_) {
          _neverSatisfied("Error conexión", "Hubo un error en la conexión");
        }

        break;
      case false:
        // ...
        print('false');
        return false;
        break;
    }
    return true;
  }

  Future<void> _neverSatisfied(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
