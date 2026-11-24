import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/models/solvexa_models.dart';
import 'providers/solvexa_provider.dart';
import 'screens/home_screen.dart';
import 'screens/new_ticket_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'screens/ticket_success_screen.dart';
import 'screens/ticket_timeline_screen.dart';
import 'widgets/solvexa_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => SolvexaProvider()..initialize(),
      child: const SolvexaMobileApp(),
    ),
  );
}

class SolvexaMobileApp extends StatelessWidget {
  const SolvexaMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solvexa Mobile – Universitas Trilogi',
      debugShowCheckedModeBanner: false,
      theme: SolvexaTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const MainShellScreen());
          case '/new-ticket':
            final asset = settings.arguments as CampusAsset?;
            return MaterialPageRoute(
              builder: (_) => NewTicketScreen(scannedAsset: asset),
            );
          case '/ticket-success':
            final ticket = settings.arguments as TicketModel?;
            return MaterialPageRoute(
              builder: (_) => TicketSuccessScreen(ticket: ticket),
            );
          case '/ticket-timeline':
            final ticket = settings.arguments as TicketModel?;
            return MaterialPageRoute(
              builder: (_) => TicketTimelineScreen(initialTicket: ticket),
            );
          default:
            return MaterialPageRoute(builder: (_) => const MainShellScreen());
        }
      },
    );
  }
}

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static const List<String> _tabTitles = [
    'Home',
    'Scan Qr',
    'Notifications',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolvexaProvider>();
    final currentTab = provider.currentTabIndex;

    final pages = const [
      HomeScreen(),
      ScanQrScreen(),
      NotificationsScreen(),
    ];

    return Scaffold(
      appBar: SolvexaTopAppBar(title: _tabTitles[currentTab]),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: currentTab,
              children: pages,
            ),
      bottomNavigationBar: SolvexaBottomNavBar(
        currentIndex: currentTab,
        onTap: provider.setTabIndex,
      ),
    );
  }
}
