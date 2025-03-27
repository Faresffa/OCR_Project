import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/ticket_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static File? _file;

  DatabaseService._init();

  Future<File> get database async {
    if (_file != null) return _file!;
    _file = await _initDB();
    return _file!;
  }

  Future<File> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/tickets.json';
    return File(path);
  }

  Future<int> insertTicket(TicketModel ticket) async {
    final file = await database;
    final tickets = await getAllTickets();
    tickets.add(ticket);
    await file.writeAsString(jsonEncode(tickets.map((t) => t.toJson()).toList()));
    return tickets.length - 1;
  }

  Future<List<TicketModel>> getAllTickets() async {
    final file = await database;
    if (!await file.exists()) return [];
    
    final String contents = await file.readAsString();
    if (contents.isEmpty) return [];
    
    final List<dynamic> decoded = jsonDecode(contents);
    return decoded.map((json) => TicketModel.fromJson(json)).toList();
  }

  Future<void> deleteTicket(int id) async {
    final file = await database;
    final tickets = await getAllTickets();
    tickets.removeAt(id);
    await file.writeAsString(jsonEncode(tickets.map((t) => t.toJson()).toList()));
  }

  Future<void> close() async {
    // Le fichier se ferme automatiquement
  }
} 