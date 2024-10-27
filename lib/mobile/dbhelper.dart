import 'package:path/path.dart';
import 'package:scrawler/models/label.dart';
import 'package:scrawler/models/notes.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'scrawler.s3db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
                  CREATE TABLE notes (
                    note_id text primary key,
                    note_date text,
                    note_title text,
                    note_text text,
                    note_label text,
                    note_archived integer,
                    note_color integer,
                    note_image text,
                    note_audio_file text,
                    note_favorite integer)
                ''');
    await db.execute('''
                  CREATE TABLE labels (label_id text primary key, label_name text)
                ''');
  }

  Future<List<Notes>> getNotesFavorite() async {
    Database? db = await database;
    var parsed = await db.query('notes',
        orderBy: 'note_title', where: 'note_favorite = 1');
    return parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
  }

  Future<List<Notes>> getNotesByFolder(String noteLabel, String sortBy) async {
    Database? db = await database;
    var parsed = await db.query('notes',
        orderBy: sortBy,
        where: noteLabel.isEmpty ? null : 'note_label = \'$noteLabel\'');

    return parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
  }

  Future<List<Notes>> getNotesUnLabeled(String sortBy) async {
    Database? db = await database;
    var parsed =
        await db.query('notes', orderBy: sortBy, where: 'note_label = \'\'');

    return parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
  }

  Future<List<Notes>> getNotesAll(String filter, String sortBy) async {
    Database? db = await database;
    var parsed = await db.query('notes',
        orderBy: sortBy,
        where: filter.isNotEmpty
            ? '(note_title LIKE \'%$filter%\' OR note_text LIKE \'%$filter%\' OR note_label LIKE \'%$filter%\')'
            : null);

    return parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
  }

  Future<List<Notes>> getNotesArchived(String filter) async {
    Database? db = await database;
    var parsed = await db.query('notes',
        orderBy: 'note_date DESC',
        where:
            'note_archived = 1 ${filter.isNotEmpty ? ' AND (note_title LIKE \'%$filter%\' OR note_text LIKE \'%$filter%\' OR note_label LIKE \'%$filter%\')' : ''}');
    return parsed.map<Notes>((json) => Notes.fromJson(json)).toList();
  }

  Future<bool> archiveNote(String noteId, int archive) async {
    Database? db = await database;
    Map<String, dynamic> map = {'note_id': noteId, 'note_archived': archive};
    String id = map['note_id'];
    final rowsAffected =
        await db.update('notes', map, where: 'note_id = ?', whereArgs: [id]);
    return (rowsAffected == 1);
  }

  Future<bool> insertNotes(Notes note) async {
    Database? db = await database;
    final rowsAffected = await db.insert('notes', note.toJson());
    return rowsAffected > 0;
  }

  Future<bool> updateNotes(Notes note) async {
    Database? db = await database;
    Map<String, dynamic> map = {
      'note_id': note.noteId,
      'note_date': note.noteDate,
      'note_title': note.noteTitle,
      'note_text': note.noteText,
      'note_color': note.noteColor,
      'note_favorite': note.noteFavorite ? 1 : 0,
      'note_label': note.noteLabel,
      'note_archived': note.noteArchived ? 1 : 0,
      'note_image': note.noteImage
    };
    String id = map['note_id'];
    final rowsAffected =
        await db.update('notes', map, where: 'note_id = ?', whereArgs: [id]);
    return (rowsAffected > 0);
  }

  Future<bool> updateNoteColor(String noteId, int noteColor) async {
    Database? db = await database;
    Map<String, dynamic> map = {
      'note_id': noteId,
      'note_color': noteColor,
      'note_date': DateTime.now().toString()
    };
    String id = map['note_id'];
    final rowsAffected =
        await db.update('notes', map, where: 'note_id = ?', whereArgs: [id]);
    return (rowsAffected == 1);
  }

  Future<bool> updateNoteLabel(String noteId, String noteLabel) async {
    Database? db = await database;
    Map<String, dynamic> map = {
      'note_id': noteId,
      'note_label': noteLabel,
      'note_date': DateTime.now().toString()
    };
    String id = map['note_id'];
    final rowsAffected =
        await db.update('notes', map, where: 'note_id = ?', whereArgs: [id]);
    return (rowsAffected == 1);
  }

  Future<bool> updateNoteFavorite(String noteId, bool fav) async {
    Database? db = await database;
    Map<String, dynamic> map = {'note_favorite': fav ? 1 : 0};
    final rowsAffected = await db
        .update('notes', map, where: 'note_id = ?', whereArgs: [noteId]);
    return (rowsAffected == 1);
  }

  Future<bool> deleteNotes(String noteId) async {
    Database? db = await database;
    int rowsAffected =
        await db.delete('notes', where: 'note_id = ?', whereArgs: [noteId]);
    return (rowsAffected == 1);
  }

  Future<bool> deleteNotesAll() async {
    Database? db = await database;
    int rowsAffected = await db.delete('notes');
    return (rowsAffected > 0);
  }

  Future<bool> clearNotes() async {
    Database? db = await database;
    int rowsAffected = await db.delete('notes');
    return (rowsAffected > 0);
  }

  Future<List<Label>> getLabelsAll() async {
    Database? db = await database;
    var parsed = await db.query('labels', orderBy: 'label_name');
    return parsed.map<Label>((json) => Label.fromJson(json)).toList();
  }

  Future<bool> insertLabel(Label label) async {
    Database? db = await database;
    int rowsAffected = await db.insert('labels', label.toJson());
    return (rowsAffected >= 0);
  }

  Future<bool> updateLabel(Label label) async {
    Database? db = await database;
    Map<String, dynamic> map = {
      'label_id': label.labelId,
      'label_name': label.labelName
    };
    String id = map['label_id'];
    final rowsAffected =
        await db.update('labels', map, where: 'label_id = ?', whereArgs: [id]);
    return (rowsAffected == 1);
  }

  Future<bool> deleteLabel(String labelId) async {
    Database? db = await database;
    int rowsAffected =
        await db.delete('labels', where: 'label_id = ?', whereArgs: [labelId]);
    return (rowsAffected == 1);
  }
}
