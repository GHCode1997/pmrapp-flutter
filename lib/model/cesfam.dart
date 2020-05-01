class Cesfam {
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final List<dynamic> telefonos;
  Cesfam(
      {this.nombre, this.descripcion, this.ubicacion, this.telefonos});

  factory Cesfam.fromJSON(Map cesfam) {
    return new Cesfam(
        nombre: cesfam['nombre'],
        descripcion: cesfam['descripcion'],
        ubicacion: cesfam['ubicacion'],
        telefonos: cesfam['telefonos']);
  }
}