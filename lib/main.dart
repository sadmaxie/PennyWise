import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// Pages
import 'package:pennywise/screens/calendar/calendar_page.dart';
import 'package:pennywise/screens/details/details_page.dart';
import 'package:pennywise/screens/home/home_page.dart';
import 'package:pennywise/screens/user/user_page.dart';
import 'package:pennywise/screens/wallets/wallets_page.dart';
import 'package:pennywise/screens/main_page.dart';
import 'package:pennywise/themes/theme.dart';

import 'database/user.dart';
import 'database/wallet_provider.dart';
import 'database/transaction_item.dart';
import 'database/wallet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2D2D49),
      systemNavigationBarColor: Color(0xFF2D2D49),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Use custom Hive directory for predictable export/import
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final hivePath = '${appDocumentDir.path}/hive';
  Hive.init(hivePath);
  print('[Hive] Initialized at: $hivePath');

  // Register Hive adapters
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(TransactionItemAdapter());
  Hive.registerAdapter(UserAdapter());

  // Open Hive boxes
  await Hive.openBox<Wallet>('walletsBox');
  await Hive.openBox<TransactionItem>('transactionsBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
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
      home:  MainPage(),
      theme: darkMode,
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
