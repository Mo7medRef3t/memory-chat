import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/env_keys.dart';

class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient _supabase;

  SupabaseConnector(this._supabase);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final endpoint = dotenv.env[EnvKeys.powerSyncUrl] ?? '';
      if (endpoint.isEmpty) return null;

      return PowerSyncCredentials(
        endpoint: endpoint,
        token: session.accessToken,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    try {
      for (final op in transaction.crud) {
        await _uploadOperation(op);
      }
      await transaction.complete();
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('permission denied') ||
          errorStr.contains('violates') ||
          errorStr.contains('foreign key') ||
          errorStr.contains('duplicate key') ||
          errorStr.contains('not-null') ||
          errorStr.contains('invalid input')) {
        await transaction.complete();
      }
    }
  }

  Future<void> _uploadOperation(CrudEntry op) async {
    final table = op.table;
    final id = op.id;

    switch (op.op) {
      case UpdateType.put:
        final data = {...?op.opData, 'id': id};
        await _supabase.from(table).upsert(data, onConflict: 'id');
        break;

      case UpdateType.patch:
        final data = {...?op.opData};
        await _supabase.from(table).update(data).eq('id', id);
        break;

      case UpdateType.delete:
        await _supabase.from(table).delete().eq('id', id);
        break;
    }
  }
}
