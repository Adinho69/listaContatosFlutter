// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = 'contactTable';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

var random = Random();

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  Database? _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db as Database;
    } else {
      _db = await initDb();
    }
    return _db as Database;
  }

  //inicializar banco de dados
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contacts.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute('CREATE TABLE $contactTable ('
          '$idColumn INTERGER PRIMARY KEY,'
          '$nameColumn TEXT,'
          '$emailColumn TEXT,'
          '$phoneColumn TEXT,'
          '$imgColumn TEXT)');
    });
  }

  //salvar contato
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = random.nextInt(
        1000); //consertar essa gabiarra aqui <------------------------------------
    await dbContact.insert(
        contactTable, contact.toMap() as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return contact;
  }

  //coletar um contato
  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: '$idColumn = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //deletar contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  //atualizar contato
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
        contactTable, contact.toMap() as Map<String, dynamic>,
        where: '$idColumn = ?', whereArgs: [contact.id]);
  }

  //coletar todos os contatos
  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery('SELECT * FROM $contactTable');
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //coletar numero de contatos
  Future<int?> getNumber() async {
    Database? dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  //encerrar banco de dados
  Future close() async {
    Database dbContact = await db;
    await dbContact.close();
  }
}

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name $name, email $email, phone $phone, img: $img)';
  }
}
