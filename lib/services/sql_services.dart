import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

const String tableNotifications = 'notifications';

const String columnId = 'id';
const String columnnotificationId = 'notificationId';
const String columntitle = 'title';
const String columnmessage = 'message';
const String columnisread = 'isread';

class BackgroundPersistence {
  factory BackgroundPersistence() {
    _backgroundPersistence ??= BackgroundPersistence._createInstance();
    return _backgroundPersistence!;
  }
  BackgroundPersistence._createInstance();
  static Database? _database;
  static BackgroundPersistence? _backgroundPersistence;

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    final dir = await getDatabasesPath();
    final path = '${dir}notify.db';

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          create table $tableNotifications ( 
          $columnId integer primary key autoincrement, 
          $columnnotificationId text not null,
          $columntitle text not null,
          $columnmessage text not null,
          $columnisread text not null)
        ''');
      },
    );
    return database;
  }

  Future<void> insertMessage(BackgroundNotification chatmessage) async {
    final db = await database;
    final result = await db.insert(tableNotifications, chatmessage.toJson());
    debugPrint('result IN Notification BACKGROUND HANDLER : $result');
  }

  Future<List<BackgroundNotification>> getMessagesBySessionId(
    String sessionId,
  ) async {
    final db = await database;
    final result = await db.query(
      tableNotifications,
      where: '$columnnotificationId = ?',
      whereArgs: [sessionId],
    );

    final messages = result.isNotEmpty
        ? result.map(BackgroundNotification.fromJson).toList()
        : <BackgroundNotification>[];
    return messages;
  }

  Future<List<BackgroundNotification>> getAllBackgroundMessages() async {
    final db = await database;
    final result = await db.query(tableNotifications);

    final messages = result.isNotEmpty
        ? result.map(BackgroundNotification.fromJson).toList()
        : <BackgroundNotification>[];
    return messages;
  }

  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete(tableNotifications);
    debugPrint('All messages deleted');
  }
}

class BackgroundNotification {
  int? id;
  String? notificationId;
  String? title;
  String? message;
  String? isread;

  BackgroundNotification({
    this.id,
    this.notificationId,
    this.title,
    this.message,
    this.isread,
  });

  factory BackgroundNotification.fromJson(Map<String, dynamic> json) {
    return BackgroundNotification(
      id: json['id'],
      notificationId: json['notificationId'],
      title: json['title'],
      message: json['message'],
      isread: json['isread'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'isread': isread,
    };
  }
}
