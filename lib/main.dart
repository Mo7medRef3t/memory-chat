import 'package:flutter/material.dart';
import 'package:memory_chat/app/app.dart';
import 'package:memory_chat/app/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MemoryChatApp());
}
