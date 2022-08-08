import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Logger {
  static final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  static late Box _appLogBox;
  static late Box _accelerometerSensorBox;
  static late Box _userAccelerometerSensorBox;
  static bool _isInit = false;
  static const _fileNameSuffix = 'USERID';
  static String _curruntPage = '';

  static void _stopSubscription() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  static initializeLogger() async {
    Hive.init((await getApplicationDocumentsDirectory()).path);
    _stopSubscription();
    _appLogBox = await Hive.openBox('appLog');
    _accelerometerSensorBox = await Hive.openBox('accelerometerSensor');
    _userAccelerometerSensorBox = await Hive.openBox('userAccelerometerSensor');

    await Future.wait([
      _saveFile(),
      _saveFile(type: 'accelerometer'),
      _saveFile(type: 'userAccelerometer'),
    ]);
    _isInit = true;
    _startSensorLogging();
  }

  static log({required String pageName, required String action, String? detail}) async {
    if (_isInit) {
      DateTime now = DateTime.now();
      _curruntPage = pageName;
      Map db = {'timeStap': now, 'pageName': pageName, 'action': action, 'detail': detail};
      await _appLogBox.add(db);
    }
  }

  static _startSensorLogging() {
    listnerCallback(Box box) {
      return (event) async {
        String valueX = event.x.toStringAsFixed(4);
        String valueY = event.y.toStringAsFixed(4);
        String valueZ = event.z.toStringAsFixed(4);
        DateTime now = DateTime.now();

        await box.add('$now,$valueX.$valueY.$valueZ,$_curruntPage\n');
      };
    }

    _streamSubscriptions.add(accelerometerEvents.listen(listnerCallback(_accelerometerSensorBox)));
    _streamSubscriptions.add(userAccelerometerEvents.listen(listnerCallback(_userAccelerometerSensorBox)));
  }

  static Future _saveFile({String type = 'appLog'}) async {
    Box box = _getBox(type);
    if (box.isNotEmpty) {
      List datas = box.values.toList();
      String path = await _getPath();
      String fileName = "$path/${type}_$_fileNameSuffix.csv";
      File file = File(fileName);
      String resultStr = _getFileData(type, datas);

      await file.writeAsString(resultStr);
      box.clear();

      _firebaseThings(type, file);
    }
  }

  static Box _getBox(String type) {
    if (type == 'appLog') {
      return _appLogBox;
    } else if (type == 'accelerometer') {
      return _accelerometerSensorBox;
    } else {
      return _userAccelerometerSensorBox;
    }
  }

  static Future<String> _getPath() async {
    String directoryPath = "";
    if (Platform.isAndroid) {
      final directory = await getTemporaryDirectory();
      directoryPath = directory.path;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      directoryPath = directory.path;
    }
    return directoryPath;
  }

  static String _getFileData(String type, List datas) {
    String resultStr = '';
    if (type == 'appLog') {
      resultStr = datas[0].keys.fold('', (str, key) => str + '$key,');
      resultStr += datas.fold('', (str, data) => '$str\n${data.values.fold('', (str_, val) => str_ + '$val,')}');
    } else {
      resultStr = datas.join();
    }
    return resultStr;
  }

  static _firebaseThings(String type, File myFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child('${DateTime.now()}_${type}_$_fileNameSuffix.csv');
    try {
      await fileRef.putFile(myFile).then((p0) => myFile.delete());
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
