class Especialidad {
  final int id;
  final String nombre;
  final String descripcion;

  Especialidad({this.id,this.nombre,this.descripcion});

  factory Especialidad.fromJSON(Map especialidad){
    return new Especialidad(
      id: especialidad['id'],
      nombre: especialidad['nombre'],
      descripcion: especialidad['descripcion']
    );
  }
}