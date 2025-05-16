/// main.dart
/// Entry point of the PennyWise app.
/// - Initializes Hive with custom path.
/// - Registers adapters.
/// - Opens local boxes for wallets and transactions.
/// - Sets system UI styles and launches the app using MultiProvider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pennywise/database/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'database/models/card_group.dart';
import 'database/models/wallet.dart';
import 'database/providers/card_group_provider.dart';
import 'database/providers/wallet_provider.dart';
import 'database/models/transaction_item.dart';
import 'database/models/user_data.dart';

import 'package:pennywise/themes/theme.dart';
import 'package:pennywise/screens/main_page.dart';
import 'package:pennywise/screens/home/home_page.dart';
import 'package:pennywise/screens/wallets/wallets_page.dart';
import 'package:pennywise/screens/calendar/calendar_page.dart';
import 'package:pennywise/screens/details/details_page.dart';
import 'package:pennywise/screens/user/user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2D2D49),
      systemNavigationBarColor: Color(0xFF2D2D49),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final appDocumentDir = await getApplicationDocumentsDirectory();
  final hivePath = '${appDocumentDir.path}/hive';
  Hive.init(hivePath);
  print('[Hive] Initialized at: $hivePath');

  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(TransactionItemAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(CardGroupAdapter());

  await Hive.openBox<Wallet>('walletsBox');
  await Hive.openBox<TransactionItem>('transactionsBox');
  await Hive.openBox<CardGroup>('cardGroupsBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => CardGroupProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkMode,
      home: MainPage(),
      routes: {
        '/home_page': (context) => const HomePage(),
        '/wallets_page': (context) => const WalletsPage(),
        '/calender_page': (context) => const CalendarPage(),
        '/details_page': (context) => const DetailsPage(),
        '/user_page': (context) => const UserPage(),
      },
    );
  }
}
