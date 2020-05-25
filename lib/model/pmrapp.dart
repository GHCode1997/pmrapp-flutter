class PMRApp {
  int id;
  String name;
  String cesfam;
  String path;

  PMRApp({this.id,this.name,this.cesfam,this.path});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      name: name,
      cesfam: cesfam,
      path: path
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory PMRApp.fromMap(Map<String,dynamic> map){
    return new PMRApp(id: map['id'],name: map['name'],cesfam: map['cesfam'],path: map['path']);
  }
}