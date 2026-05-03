import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secura/ui/Home Screen/home_screen.dart';
import 'model/vault_item.dart';
import 'package:feedback/feedback.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VaultItemAdapter());
  await Hive.openBox<VaultItem>('vault');
  runApp(
    BetterFeedback(
    localeOverride: const Locale('en'),
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Secura Vault",
      home: VaultHome(),
    );
  }
}
