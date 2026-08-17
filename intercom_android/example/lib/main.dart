import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intercom_platform_interface/intercom_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: make sure to add keys from your Intercom workspace.
  await IntercomPlatform.instance.initialize(
    appId: 'your_app_id',
    androidApiKey: 'your_android_api_key',
  );
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<dynamic>? _streamSubscription;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription = IntercomPlatform.instance.getUnreadStream().listen(
          (event) => debugPrint('UnreadStream EVENT: $event'),
          onError: (e, stack) => debugPrint('UnreadStream ERROR: $e; stack: $stack'),
          onDone: () => debugPrint('UnreadStream DONE'),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intercom example app'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                IntercomPlatform.instance.logout();
                IntercomPlatform.instance.loginIdentifiedUser(
                  userId: '123456789',
                  email: 'example@gmail.com',
                  statusCallback: IntercomStatusCallback(
                    onSuccess: () async {
                      await IntercomPlatform.instance.displayMessenger();
                      await Future.delayed(const Duration(seconds: 5), () {
                        IntercomPlatform.instance.hideMessenger();
                      });
                    },
                    onFailure: (IntercomError error) {
                      debugPrint(error.toString());
                    },
                  ),
                );
              },
              child: const Text('Show messenger'),
            ),
            TextButton(
              onPressed: () {
                IntercomPlatform.instance.setLauncherVisibility(IntercomVisibility.visible);
              },
              child: const Text('Show launcher'),
            ),
            TextButton(
              onPressed: () {
                IntercomPlatform.instance.setLauncherVisibility(IntercomVisibility.gone);
              },
              child: const Text('Hide launcher'),
            ),
            TextButton(
              onPressed: () {
                IntercomPlatform.instance.displayHelpCenter();
              },
              child: const Text('Display help center'),
            ),
          ],
        ),
      ),
    );
  }
}
