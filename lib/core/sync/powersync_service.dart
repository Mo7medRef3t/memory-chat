import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_connector.dart';
import 'package:path/path.dart' as p;

class PowerSyncService {
  PowerSyncDatabase? _db;
  SupabaseConnector? _connector;
  bool _initialized = false;
  bool _connected = false;

  PowerSyncDatabase get database {
    if (_db == null) throw StateError('PowerSync not initialized');
    return _db!;
  }

  bool get isInitialized => _initialized;
  bool get isConnected => _connected;

  Future<void> initialize() async {
    if (_initialized) return;

    _connector = SupabaseConnector(Supabase.instance.client);
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'memory_chat_unified.db');

    _db = PowerSyncDatabase(schema: _buildSchema(), path: dbPath);

    await _db!.initialize();
    _initialized = true;
  }

  Future<void> connect() async {
    if (!_initialized || _connector == null) return;
    if (_connected) return;

    await _db!.connect(connector: _connector!);
    _connected = true;
  }

  Future<void> disconnect() async {
    if (!_connected || _db == null) return;
    await _db!.disconnect();
    _connected = false;
  }

  Future<void> clearDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'memory_chat_unified.db');
    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    _initialized = false;
    _connected = false;
  }

  Schema _buildSchema() {
    return Schema([
      Table('profiles', [
        Column.text('email'),
        Column.text('full_name'),
        Column.text('avatar_url'),
        Column.text('created_at'),
        Column.text('updated_at'),
      ]),
      Table('workspaces', [
        Column.text('name'),
        Column.text('description'),
        Column.text('owner_id'),
        Column.text('created_at'),
        Column.text('updated_at'),
      ]),
      Table('workspace_members', [
        Column.text('workspace_id'),
        Column.text('user_id'),
        Column.text('role'),
        Column.text('joined_at'),
      ]),
      Table('sections', [
        Column.text('workspace_id'),
        Column.text('title'),
        Column.text('created_at'),
        Column.text('updated_at'),
      ]),
      Table('memory_boxes', [
        Column.text('workspace_id'),
        Column.text('section_id'),
        Column.text('title'),
        Column.text('description'),
        Column.text('created_at'),
        Column.text('updated_at'),
      ]),
      Table('notes', [
        Column.text('memory_box_id'),
        Column.text('author_id'),
        Column.text('title'),
        Column.text('content'),
        Column.text('created_at'),
        Column.text('updated_at'),
      ]),
    ]);
  }
}
