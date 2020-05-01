import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer2/mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pmrapp/model/hora.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HoraQR extends StatefulWidget {
  HoraQR(this.horaPaciente, this.username);
  _HoraQRState createState() => _HoraQRState();
  final String username;
  final Hora horaPaciente;
}

class _HoraQRState extends State<HoraQR> {
  TextEditingController emailSender = new TextEditingController();
  GlobalKey globalKey = new GlobalKey();
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
                    widget.username +
                    '&fecha=' +
                    widget.horaPaciente.fecha +
                    '&hora=' +
                    widget.horaPaciente.hora +
                    '&medico=' +
                    widget.horaPaciente.medico.run,
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
                onPressed: () {
                  _captureAndSharePng();
                })
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSharePng() async {
    var options = new GmailSmtpOptions()
      ..username = 'pmrappserviciotecnico@gmail.com'
      ..password = 'r9HDDprmPMCWAEK';
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file =
          await new File('${tempDir.path}/qr_${widget.horaPaciente.id}.png')
              .create();
      await file.writeAsBytes(pngBytes);
      var emailTransport = new SmtpTransport(options);
      var envelope = new Envelope()
        ..from = 'pmrappserviciotecnico@gmail.com'
        ..recipients.add(this.emailSender.text)
        ..subject = 'Envio de qr'
        ..attachments.add(new Attachment(file: file))
        ..text =
            'Este qr se utilizará para validar su hora agendada. \n Por favor presentar en el cesfam.\n Saludos pmrapp'
        ..html = '<h1>Test</h1><p>Hey!</p>';
      showAlertDialog(context);
      emailTransport
          .send(envelope)
          .then((envelope){ Navigator.pop(context); Navigator.pop(context);})
          .catchError((e) => print('Error occurred: $e'));
    } catch (e) {
      print(e.toString());
    }
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5), child: Text("Enviando...")),
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
