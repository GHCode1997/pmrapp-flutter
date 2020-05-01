import 'cesfam.dart';
import 'especialidad.dart';

class Medico {
  final String nombres;
  final String apellidos;
  final String run;
  final bool cronico;
  final Cesfam cesfam;
  final Especialidad especialidad;
  Medico(
      {this.nombres, this.apellidos, this.especialidad, this.run, this.cronico, this.cesfam});

  factory Medico.fromJSON(Map medico) {
    return new Medico(
        nombres: medico['nombres'],
        apellidos: medico['apellidos'],
        run: medico['run'],
        cronico: medico['cronico'],
        cesfam: Cesfam.fromJSON(medico['cesfam']),
        especialidad: Especialidad.fromJSON(medico['especialidad']));
  }
}