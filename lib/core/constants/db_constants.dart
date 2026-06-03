import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DbConstants {
  static Future<String> get dbPath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'memory_chat_unified.db');
  }
}
