import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class SubscribeToCommunity extends StatefulWidget {
  const SubscribeToCommunity({super.key});

  @override
  State<SubscribeToCommunity> createState() => _SubscribeToCommunityState();
}

class _SubscribeToCommunityState extends State<SubscribeToCommunity> {
  late HiveFlutterKitPlatform hfk;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hfk = HiveFlutterKitPlatform.instance;
  }

  void subscribeToCommunity() {
    hfk.subscribeUnsubscribeToCommunity('hive-151954', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Subscribe to Community',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      appBar: AppBar(title: Text('Subscribe')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          subscribeToCommunity();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
