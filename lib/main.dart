/// main.dart sets up the Pennywise app:
/// - Initializes Hive storage and adapters
/// - Sets system UI styling
/// - Loads providers and notifications
/// - Launches the app with routing and themes

import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:pennywise/database/providers/notification_provider.dart';

import 'package:pennywise/services/notification_service.dart';
import 'package:pennywise/themes/theme.dart';
import 'package:pennywise/screens/main_page.dart';
import 'package:pennywise/utils/restart_widget.dart';

@pragma('vm:entry-point')
void alarmCallbackDispatcher() async {
  final plugin = FlutterLocalNotificationsPlugin();

  const android = AndroidInitializationSettings('@mipmap/launcher_icon');
  const ios = DarwinInitializationSettings();
  const settings = InitializationSettings(android: android, iOS: ios);
  await plugin.initialize(settings);

  await plugin.show(
    999,
    'Reminder',
    '⏰ Time to log your spending!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel_id',
        'Instant Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  tz.initializeTimeZones();
  await NotificationService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2D2D49),
      systemNavigationBarColor: Color(0xFF2D2D49),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const RestartWidget(child: MyApp()));
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

          final userProvider = UserProvider();
          userProvider.loadUser();

          final notificationProvider = NotificationProvider();
          notificationProvider.initialize();

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => WalletProvider()),
              ChangeNotifierProvider(create: (_) => userProvider),
              ChangeNotifierProvider(create: (_) => CardGroupProvider()),
              ChangeNotifierProvider(create: (_) => DetailsProvider()),
              ChangeNotifierProvider(create: (_) => notificationProvider),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: darkMode,
              home: const MainPage(),
              routes: {
                '/home_page': (context) => const MainPage(),
                '/wallets_page': (context) => const MainPage(),
                '/calender_page': (context) => const MainPage(),
                '/details_page': (context) => const MainPage(),
                '/user_page': (context) => const MainPage(),
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
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(TransactionItemAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CardGroupAdapter());
    if (!Hive.isAdapterRegistered(4))
      Hive.registerAdapter(NotificationTimeAdapter());

    await Hive.openBox<Wallet>('walletsBox');
    await Hive.openBox<TransactionItem>('transactionsBox');
    await Hive.openBox<CardGroup>('cardGroupsBox');
    await Hive.openBox<User>('userBox');
    await Hive.openBox<NotificationTime>('notificationTimes');
  }
}
