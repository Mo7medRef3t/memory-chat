import 'package:uuid/uuid.dart';

class IdGenerator {
  final Uuid _uuid;

  IdGenerator(this._uuid);

  String generate() {
    return _uuid.v4();
  }
}
