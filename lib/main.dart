import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gorev_uygulamasi/data/local_storage.dart';
import 'package:flutter_gorev_uygulamasi/models/task_model.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/home_page.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerSingleton<LocalStorage>(HiveLocalStorage());
}

Future<void> setupHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  var taskBox = await Hive.openBox<Task>("tasks");
  taskBox.values.forEach((element) {
    for (var task in taskBox.values) {
      if (task.createdAt.day != DateTime.now().day) {
        taskBox.delete(task.id);
      } // gün geçince görevleri silme
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await setupHive();
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)),
      ),
      home: const HomePage(),
    );
  }

  // mehmetkarakus0058@gmail.com
}
