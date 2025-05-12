import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Pages
import 'package:pennywise/screens/calendar/calendar_page.dart';
import 'package:pennywise/screens/details/details_page.dart';
import 'package:pennywise/screens/home/home_page.dart';
import 'package:pennywise/screens/user/user_page.dart';
import 'package:pennywise/screens/wallets/wallets_page.dart';
import 'package:pennywise/screens/main_page.dart';
import 'package:pennywise/themes/theme.dart';

import 'components/wallet_provider.dart';
import 'database/transaction_item.dart';
import 'database/wallet.dart';

// Models

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2D2D49),
      systemNavigationBarColor: Color(0xFF2D2D49),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(TransactionItemAdapter());

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
      home: MainPage(),
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

