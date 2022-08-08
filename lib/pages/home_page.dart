import 'package:file_auto_upload_test/components/logger.dart';
import 'package:file_auto_upload_test/pages/test_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await Logger.log(action: 'page_start', pageName: 'home_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button01');
                    },
                    child: const Text('로깅 버튼1')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button02');
                    },
                    child: const Text('로깅 버튼2')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button03');
                    },
                    child: const Text('로깅 버튼3')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button04');
                    },
                    child: const Text('로깅 버튼4')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button05');
                    },
                    child: const Text('로깅 버튼5')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button06');
                    },
                    child: const Text('로깅 버튼6')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button07');
                    },
                    child: const Text('로깅 버튼7')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'button08');
                    },
                    child: const Text('로깅 버튼8')),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => const TestPage());
              },
              child: Text('Open Other Page'),
            ),
            ElevatedButton(
              onPressed: () async {
                  var  testBox1 = await Hive.openBox('test2');
                  print(testBox1.values.toList().length);
              },
              child: Text('test'),
            ),
            
            // SizedBox(height: 50),
            // ElevatedButton(
            //   onPressed: () async {
            //     Map appLogData = widget.isFileUploaded['applog'];
            //     if (appLogData['success']) {
            //       String url = appLogData['url'];
            //       // if (await canLaunchUrlString(url)) launchUrlString(url);
            //       launchUrlString(url, mode: LaunchMode.externalNonBrowserApplication);
            //     }
            //   },
            //   child: Text('appLogFileDownload'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     Map appLogData = widget.isFileUploaded['sensor1'];
            //     if (appLogData['success']) {
            //       String url = appLogData['url'];
            //       // if (await canLaunchUrlString(url)) launchUrlString(url);
            //       launchUrlString(url, mode: LaunchMode.externalNonBrowserApplication);
            //     }
            //   },
            //   child: Text('appLogFileDownload'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     Map appLogData = widget.isFileUploaded['sensor2'];
            //     if (appLogData['success']) {
            //       String url = appLogData['url'];
            //       // if (await canLaunchUrlString(url)) launchUrlString(url);
            //       launchUrlString(url, mode: LaunchMode.externalNonBrowserApplication);
            //     }
            //   },
            //   child: Text('appLogFileDownload'),
            // )
          ],
        ),
      ),
    );
  }
}
