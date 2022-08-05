import 'package:file_auto_upload_test/components/logger.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await Logger.log(action: 'page_start', pageName: 'test_page');
  }

  @override
  void dispose() {
    super.dispose();
    exit();
  }

  exit() async {
    await Logger.log(action: 'page_end', pageName: 'test_page');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'sub-button01');
                    },
                    child: const Text('sub page 로깅 버튼1')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'sub-button02');
                    },
                    child: const Text('sub page 로깅 버튼2')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'sub-button03');
                    },
                    child: const Text('sub page 로깅 버튼3')),
                ElevatedButton(
                    onPressed: () async {
                      await Logger.log(action: 'button_click', pageName: 'home_page', detail: 'sub-button04');
                    },
                    child: const Text('sub page 로깅 버튼4')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
