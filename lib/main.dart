/// main.dart
/// Entry point of the PennyWise app.
/// - Initializes Hive with custom path.
/// - Registers adapters.
/// - Opens local boxes for wallets, transactions, cards, users, and notifications.
/// - Sets system UI styles and launches the app using MultiProvider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:pennywise/database/models/card_group.dart';
import 'package:pennywise/database/models/wallet.dart';
import 'package:pennywise/database/models/transaction_item.dart';
import 'package:pennywise/database/models/user_data.dart';
import 'package:pennywise/database/models/notification_time.dart';
import 'package:pennywise/database/providers/card_group_provider.dart';
import 'package:pennywise/database/providers/details_provider.dart';
import 'package:pennywise/database/providers/user_provider.dart';
import 'package:pennywise/database/providers/wallet_provider.dart';
import 'package:pennywise/services/notification_service.dart';

import 'package:pennywise/utils/restart_widget.dart';
import 'package:pennywise/themes/theme.dart';
import 'package:pennywise/screens/main_page.dart';
import 'package:pennywise/screens/home/home_page.dart';
import 'package:pennywise/screens/wallets/wallets_page.dart';
import 'package:pennywise/screens/calendar/calendar_page.dart';
import 'package:pennywise/screens/details/details_page.dart';
import 'package:pennywise/screens/user/user_page.dart';

import 'database/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

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

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(WalletAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionItemAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CardGroupAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(NotificationTimeAdapter());

  await Hive.openBox<Wallet>('walletsBox');
  await Hive.openBox<TransactionItem>('transactionsBox');
  await Hive.openBox<CardGroup>('cardGroupsBox');
  await Hive.openBox<User>('userBox');
  await Hive.openBox<NotificationTime>('notificationTimes');

  final userProvider = UserProvider();
  await userProvider.loadUser();

  runApp(
    RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => userProvider),
          ChangeNotifierProvider(create: (_) => CardGroupProvider()),
          ChangeNotifierProvider(create: (_) => DetailsProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void restartApp(BuildContext context) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: FutureBuilder(
        future: _initHiveAndProviders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => WalletProvider()),
              ChangeNotifierProvider(
                create: (_) {
                  final userProvider = UserProvider();
                  userProvider.loadUser();
                  return userProvider;
                },
              ),
              ChangeNotifierProvider(create: (_) => CardGroupProvider()),
            ],
            child: MaterialApp(
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
            ),
          );
        },
      ),
    );
  }

  Future<void> _initHiveAndProviders() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final hivePath = '${appDocumentDir.path}/hive';
    Hive.init(hivePath);

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(WalletAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionItemAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CardGroupAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(NotificationTimeAdapter());

    await Hive.openBox<Wallet>('walletsBox');
    await Hive.openBox<TransactionItem>('transactionsBox');
    await Hive.openBox<CardGroup>('cardGroupsBox');
    await Hive.openBox<User>('userBox');
    await Hive.openBox<NotificationTime>('notificationTimes');
  }
}
