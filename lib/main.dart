import 'package:file_auto_upload_test/components/logger.dart';
import 'package:file_auto_upload_test/firebase_options.dart';
import 'package:file_auto_upload_test/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Map isFileUploaded = await Logger.initializeLogger();
  await Logger.log(action: 'app_start', pageName: 'start_page');
  await Logger.log(action: 'page_start', pageName: 'start_page');

  runApp(MyApp(
    isFileUploaded: isFileUploaded,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.isFileUploaded}) : super(key: key);
  final Map isFileUploaded;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(isFileUploaded: isFileUploaded),
    );
  }
}
