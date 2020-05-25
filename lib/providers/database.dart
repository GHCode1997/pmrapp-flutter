import 'package:pmrapp/model/pmrapp.dart';
import 'package:sqflite/sqflite.dart';

class PMRDatabase {
  Database db;

  String tablePMR = "pmrapp";
  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tablePMR ( 
  id  integer primary key autoincrement, 
  name text not null,
  cesfam text not null,
  path text)
''');
    });
  }

  Future<PMRApp> insert(PMRApp todo) async {
    todo.id = await db.insert(tablePMR, {'name': todo.name, 'cesfam': todo.cesfam});
    return todo;
  }

  Future<PMRApp> getPMRApp(int id) async {
    List<Map> maps = await db.query(tablePMR,
        columns: ['id', 'name', 'cesfam', 'path'],
        where: 'id = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return PMRApp.fromMap(maps.first);
    }
    return null;
  }
  Future<int> update(PMRApp todo) async {
    return await db.update(tablePMR, {'name': todo.name,'cesfam': todo.cesfam,'path':todo.path},
        where: 'id = ?', whereArgs: [todo.id]);
  }
  Future close() async => db.close();
}
