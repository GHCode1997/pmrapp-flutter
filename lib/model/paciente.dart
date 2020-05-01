import 'cesfam.dart';

class Paciente {
  final String nombres;
  final String apellidos;
  final String direccion;
  final String urlImagen;
  final bool cronico;
  final Cesfam cesfam;
  Paciente(
      {this.nombres, this.apellidos, this.direccion, this.urlImagen, this.cronico, this.cesfam});

  factory Paciente.fromJSON(Map paciente) {
    if(paciente != null){
      return new Paciente(
        nombres: paciente['nombres'],
        apellidos: paciente['apellidos'],
        direccion: paciente['direccion'],
        urlImagen: paciente['urlImagen'],
        cronico: paciente['cronico'],
        cesfam: Cesfam.fromJSON(paciente['cesfam']));
    }
    return null;
  }
}