import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mailer2/mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pmrapp/model/hora.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/storage.service.dart';

class HoraQR extends StatelessWidget {
  HoraQR(this.horaPaciente, this.username);
  final String username;
  final Hora horaPaciente;
  final TextEditingController emailSender = new TextEditingController();
  final GlobalKey globalKey = new GlobalKey();
  File qr;
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RepaintBoundary(
              key: this.globalKey,
              child: QrImage(
                data: 'paciente=' +
                    username +
                    '&fecha=' +
                    horaPaciente.fecha +
                    '&hora=' +
                    horaPaciente.hora +
                    '&medico=' +
                    horaPaciente.medico.run,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
                size: 320,
                gapless: false,
                embeddedImage: AssetImage('assets/images/logo2.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),
            TextFormField(
              controller: emailSender,
              decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  hintText:
                      'Ingrese el email donde se va a enviar el codigo qr de atención'),
            ),
            MaterialButton(
                child: Text('Enviar'),
                onPressed: () async {
                  RenderRepaintBoundary boundary =
                      globalKey.currentContext.findRenderObject();
                  var image = await boundary.toImage();
                  ByteData byteData =
                      await image.toByteData(format: ImageByteFormat.png);
                  Uint8List pngBytes = byteData.buffer.asUint8List();

                  final tempDir = await getTemporaryDirectory();
                  final fileq = await new File(
                          '${tempDir.path}/qr_${horaPaciente.id}.png')
                      .create();
                  this.qr = await fileq.writeAsBytes(pngBytes);
                  FirebaseStorageService.loadImage(this.qr, 'qr_${horaPaciente.id}_$username');
                  _captureAndSharePng(context);
                })
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSharePng(BuildContext context) async {
    var options = new GmailSmtpOptions()
      ..username = 'pmrappserviciotecnico@gmail.com'
      ..password = 'r9HDDprmPMCWAEK';
    try {
      var emailTransport = new SmtpTransport(options);
      var envelope = new Envelope()
        ..from = 'pmrappserviciotecnico@gmail.com'
        ..recipients.add(this.emailSender.text)
        ..subject = 'Envio de qr'
        ..attachments.add(new Attachment(file: this.qr))
        ..text =
            'Este qr se utilizará para validar su hora agendada. \n Por favor presentar en el cesfam.\n Saludos pmrapp'
        ..html = '<h1>PMRAPP</h1><p>Estamos a su servicio</p>';
      showAlertDialog(context);
      emailTransport.send(envelope).then((envelope) {
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((e) => print('Error occurred: $e'));
    } catch (e) {
      print(e.toString());
    }
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 5), child: Text("Enviando...")),
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
}
