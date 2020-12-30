import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class Contacto {
  int id;
  String nombre = "";
  String apellidos = "";
  String telefono = "";
  String direccion = "";

  Contacto(this.nombre,this.apellidos,this.telefono,this.direccion);

  Map<String, dynamic> toMap(){
    return{
      "nombre": nombre,
      "apellidos": apellidos,
      "telefono": telefono,
      "direccion": direccion,
    };
  }

  Contacto.fromMap(Map<String, dynamic> map){
    id = map['id'];
    nombre = map['nombre'];
    apellidos = map['apellidos'];
    telefono = map['telefono'];
    direccion = map['direccion'];
  }
}

class ContactDataBase{
  Database database;
  initDB() async{
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'contact.db');
     database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE contacto (id INTEGER PRIMARY KEY, nombre TEXT, apellidos TEXT, telefono TEXT, direccion TEXT)');
        });
  }

  insert(Contacto contacto) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'contact.db');
    database = await openDatabase(path, version: 1);
    await database.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO contacto(nombre, apellidos, telefono, direccion) VALUES(?, ?, ?, ?)',
          [contacto.nombre.toString(), contacto.apellidos.toString(), contacto.telefono.toString(), contacto.direccion.toString()]);
      print('inserted2: $id');
    });
  }

  Future<List<Contacto>>getAll() async{
    List<Map<String, dynamic>> results = await await database.rawQuery('SELECT * FROM contacto');
    return results.map((e) => Contacto.fromMap(e)).toList();
  }

  delete(Contacto contacto) async{
    // Delete a record
    int count = await database.rawDelete('DELETE FROM contacto WHERE id = ?', [contacto.id]) ;
    assert(count == 1);
  }

}