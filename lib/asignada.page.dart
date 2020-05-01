import 'package:flutter/material.dart';
import 'package:pmrapp/services/locator.service.dart';
import 'menu_lateral.dart';
import 'services/user.service.dart';
import 'dart:convert';
import 'model/hora.dart';

class SolicitudesPage extends StatefulWidget {
  SolicitudesPage({Key key,}) : super(key: key);
  @override
  _SolicitudesPageState createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  var horas = new List<Hora>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Horas Solicitadas"),
        ),
        drawer: MenuLateral(),
        body: ListView.builder(
          itemCount: horas.length,
          itemBuilder: (context, index) {
            return Center(
                child: Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                ListTile(
                  leading: Icon(Icons.add_alert),
                  title: Text(horas[index].fecha),
                  subtitle: Text(horas[index].hora),
                ),
                SizedBox(
                  height: 25.0,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    'Dr. ' +
                        horas[index].medico.nombres +
                        ' ' +
                        horas[index].medico.apellidos,
                  ), 
                  subtitle: Text(horas[index].medico.especialidad.nombre),
                )
              ]),
            ));
          },
        ));
  }

  _getHoras() {
    locator<UserService>().getListHorasSolicitadas().then((response) {
      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> list = json.decode(response.body);
          list.forEach((f) => horas.add(Hora.fromJSON(f)));
        });
      }
    });
  }

  initState() {
    super.initState();
    _getHoras();
  }

  dispose() {
    super.dispose();
  }

}
