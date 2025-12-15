import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'delivery.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE clients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      password TEXT,
      tipo INTEGER
      )
      ''');

    await db.execute('''
    CREATE TABLE package (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_client INTEGER,
      origem TEXT,
      destino TEXT,
      situacao TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE driver_package (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_driver integer,
      id_package integer
    )
    ''');


    // Inserir um cliente de teste
    await db.insert('clients', {
      'email': 'cliente@teste.com',
      'password': '123456',
      'tipo': 0
    });

    // Inserir um motorista de teste
    await db.insert('clients', {
      'email': 'motorista@teste.com',
      'password': '123456',
      'tipo': 1
    });

    // //inserir uma entrega de teste
    // await db.insert('package', {
    //   'origem': 'Rua Cláudio Manoel, 1162 - Savassi, Belo Horizonte - MG',
    //   'destino': 'Rua Hildebrando de Oliveira, 345 - Copacabana, Belo Horizonte - MG',
    //   'situacao': 0 // 0 = pendente, 1 = em andamento, 2 = concluída
    // });
  }

  Future<bool> validateClient(String email, String password, int tipo) async {
    final db = await database;
    final result = await db.query(
      'clients',
      where: 'email = ? AND password = ? AND tipo = ?',
      whereArgs: [email, password, tipo],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getClientByLogin(String email, String password, int tipo) async {
    final db = await database;
    final result = await db.query(
      'clients',
      where: 'email = ? AND password = ? AND tipo = ?',
      whereArgs: [email, password, tipo],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getPackagesInProgressForClient(int clientId) async {
    final db = await database;
    return await db.query(
      'package',
      where: 'id_client = ? AND situacao = ?',
      whereArgs: [clientId, '1'], // '1' representa "em andamento"
    );
  }

  //FIREBASE SECTION
  Future<Map<String, dynamic>?> getClientByLoginFirebase(String email, String password, int tipo) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('entregas')
        .doc('clients')
        .collection('client')
        .where('email', isEqualTo: email)
        .where('senha', isEqualTo: password)
        .where('tipo', isEqualTo: tipo)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id; // inclui o ID do documento se precisar
      return data;
    } else {
      return null;
    }
  }
}
