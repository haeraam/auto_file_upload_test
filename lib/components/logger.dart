import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Logger {
  static final Logger _logger = Logger.initial();

  factory Logger() {
    return _logger;
  }

  Logger.initial();

  static late Box appLogBox;
  static late Box sensorBox;
  static late Box sensorBox2;
  static bool isInit = false;
  static String _saveFileName = 'USERID';

  static initializeLogger() async {
    Hive.init((await getApplicationDocumentsDirectory()).path);
    stopSubscription();
    appLogBox = await Hive.openBox('appLogBox');
    sensorBox = await Hive.openBox('sensorBox');
    sensorBox2 = await Hive.openBox('sensorBox2');
    Map res = await saveFile();
    Map resSensor = await saveFile(type: 'sensor1');
    Map resSensor2 = await saveFile(type: 'sensor2');
    isInit = true;
    logSensor();
    return {
      'applog':res,
      'sensor1':resSensor,
      'sensor2':resSensor2,
    };
  }

  static log({required String pageName, required String action, String? detail}) async {
    if (isInit) {
      DateTime now = DateTime.now();

      Map db = {
        'timeStap': now,
        'pageName': pageName,
        'action': action,
        'detail': detail,
      };

      await appLogBox.add(db);
    }
  }

  static final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  static void stopSubscription() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  static logSensor() {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) async {
          String valueX = event.x.toStringAsFixed(4);
          String valueY = event.y.toStringAsFixed(4);
          String valueZ = event.z.toStringAsFixed(4);

          if (valueX == "-0.000") {
            valueX = "0.000";
          }

          if (valueY == "-0.000") {
            valueY = "0.000";
          }

          if (valueZ == "-0.000") {
            valueZ = "0.000";
          }

          DateTime now = DateTime.now();
          int currentMilliSeconds = now.millisecondsSinceEpoch;
          DateTime date = DateTime.fromMillisecondsSinceEpoch(currentMilliSeconds);

          Map db = {
            'timeStap': now,
            'sensorData': '$valueX.$valueY.$valueY',
          };

          await sensorBox.add(db);
        },
      ),
    );

    userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) async {
        String valueX = event.x.toStringAsFixed(4);
        String valueY = event.y.toStringAsFixed(4);
        String valueZ = event.z.toStringAsFixed(4);

        if (valueX == "-0.0000") {
          valueX = "0.0000";
        }

        if (valueY == "-0.0000") {
          valueY = "0.0000";
        }

        if (valueZ == "-0.0000") {
          valueZ = "0.0000";
        }

        DateTime now = DateTime.now();
        int currentMilliSeconds = now.millisecondsSinceEpoch;
        DateTime date = DateTime.fromMillisecondsSinceEpoch(currentMilliSeconds);
        Map db = {
          'timeStap': now,
          'sensorData': '$valueX.$valueY.$valueY',
        };
        await sensorBox2.add(db);
      },
    );
  }

  static saveFile({String type = 'appLog'}) async {
    DateTime startTime = DateTime.now();
    Map res = {'success': false};
    // Hive.init((await getApplicationDocumentsDirectory()).path);
    // var logBox = await Hive.openBox('logBox');
    var box = type == 'appLog'
        ? appLogBox
        : type == 'sensor1'
            ? sensorBox
            : sensorBox2;
    if (box.isNotEmpty) {
      var datas = box.values.toList();
      DateTime getDataCompleteTime = DateTime.now();
      int diff0 = getDataCompleteTime.difference(startTime).inSeconds;

      String directoryPath = "";
      if (Platform.isAndroid) {
        final directory = await getTemporaryDirectory();
        directoryPath = directory.path;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        directoryPath = directory.path;
      }
      // checkFileExist(directoryPath);
      String fileName = "$directoryPath/${type}_$_saveFileName.csv";
      File myFile = File(fileName);
      String resultStr = '';

      DateTime fileLoadCompleteTime = DateTime.now();
      int diff1 = fileLoadCompleteTime.difference(getDataCompleteTime).inSeconds;

//여기서 시간이 오래걸림 여기 보면 됨!!
      for (var data in datas) {
        if (resultStr.isNotEmpty) {
          resultStr += "\n";
        }
        resultStr += getDataByModel(type, data);
      }

      DateTime endTime = DateTime.now();
      int diff2 = endTime.difference(fileLoadCompleteTime).inSeconds;
      int diff3 = endTime.difference(startTime).inSeconds;

      resultStr += '\n get data from local DB:,$diff0 sec';
      resultStr += '\n make file object :,$diff1 sec';
      resultStr += '\n for loop :,$diff2 sec';
      resultStr += '\n total time :,$diff3 sec';

      await myFile.writeAsString(resultStr);
      box.clear();

      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child('${DateTime.now()}_${type}_$_saveFileName.csv');
      try {
        await fileRef.putFile(myFile).then((p0) => myFile.delete());
        res = {'success': true, 'url': (await fileRef.getDownloadURL())};
      } on FirebaseException catch (e) {
        print(e);
      }
    }

    return res;
  }

  static Future checkFileExist(String directoryPath) async {
    if (_saveFileName.isEmpty) {
      return;
    }

    int index = 1;

    while (true) {
      String accelerometerName = "$directoryPath/logger_$_saveFileName.csv";

      if (File(accelerometerName).existsSync()) {
        if (_saveFileName.contains("_(")) {
          _saveFileName = "${_saveFileName.substring(0, _saveFileName.indexOf("_("))}_(${index.toString()})";
        } else {
          _saveFileName = "${_saveFileName}_(${index.toString()})";
        }

        index++;
      } else {
        break;
      }
    }
  }
}

class BasicLogModel {
  late DateTime timeStap;
  late String pageName;
  late String action;
  late String? detail;

  BasicLogModel({required this.timeStap, required this.pageName, required this.action, this.detail});

  BasicLogModel.fromJson(Map<dynamic, dynamic> json) {
    timeStap = json['timeStap'];
    pageName = json['pageName'];
    action = json['action'];
    detail = json['detail'] ?? '';
  }

  @override
  String toString() {
    return '$timeStap,$pageName,$action,$detail';
  }
}

class sensor1Model {
  late DateTime timeStap;
  late String? sensorData;

  sensor1Model({required this.timeStap, required this.sensorData});

  sensor1Model.fromJson(Map<dynamic, dynamic> json) {
    timeStap = json['timeStap'];
    sensorData = json['sensorData'];
  }

  @override
  String toString() {
    return '$timeStap,$sensorData';
  }
}

class sensor2Model {
  late DateTime timeStap;
  late String? sensorData;

  sensor2Model({required this.timeStap, required this.sensorData});

  sensor2Model.fromJson(Map<dynamic, dynamic> json) {
    timeStap = json['timeStap'];
    sensorData = json['sensorData'];
  }

  @override
  String toString() {
    return '$timeStap,$sensorData';
  }
}

String getDataByModel(String type, data) {
  String res = '';
  switch (type) {
    case 'appLog':
      res = BasicLogModel.fromJson(data).toString();
      break;
    case 'sensor1':
      res = sensor1Model.fromJson(data).toString();
      break;
    case 'sensor2':
      res = sensor2Model.fromJson(data).toString();
      break;
  }
  return res;
}
