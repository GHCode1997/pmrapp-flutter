
import 'medico.dart';
import 'paciente.dart';

class Hora {
  final int id;
  final String hora;
  final String fecha;
  final String qr;
  final bool realizada;
  final bool asignada;
  final String observacion;
  final Medico medico;
  final Paciente paciente;
  Hora(
      {this.id,this.hora, this.fecha, this.qr,this.realizada, this.asignada, this.observacion, this.medico, this.paciente});

  factory Hora.fromJSON(Map hora) {
    return new Hora(
        id: hora['id'],
        hora: hora['horaConsulta'],
        fecha: hora['fechaConsulta'],
        qr: hora['qr'],
        realizada: hora['realizada'],
        asignada: hora['asignada'],
        observacion: hora['observacion'],
        medico: Medico.fromJSON(hora['profesional']),
        paciente: Paciente.fromJSON(hora['paciente']));
  }
}
