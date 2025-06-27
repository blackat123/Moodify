import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moodify/screens/auth_screen.dart';
import 'package:moodify/screens/get_started_screen.dart';
import 'package:moodify/screens/home_screen.dart';
import 'package:moodify/services/supabase_service.dart';
import 'package:moodify/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Untuk memastikan flutter terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk local storage
  await Hive.initFlutter();
  await Hive.openBox('app_settings');

  // Inisialisasi supabase untuk database
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

// Supabase client instanse
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider(
      create: (context) => SupabaseService(),
      child: MaterialApp(
        title: 'Moodify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(textTheme).copyWith(
            bodyMedium: GoogleFonts.inter(textStyle: textTheme.bodyMedium),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Box appSettingsBox;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    appSettingsBox = Hive.box('app_settings');
    checkFirstTime();

    // Auth state change listener
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (mounted) setState(() {});
    });
  }

  // First time check function
  void checkFirstTime() {
    final firstTime = appSettingsBox.get('isFirstTime', defaultValue: true);
    if (mounted) {
      setState(() {
        isFirstTime = firstTime;
      });
    }
  }

  // Mark as not first time function
  void markAsNotFirstTime() {
    appSettingsBox.put('isFirstTime', false);
    if (mounted) {
      setState(() {
        isFirstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstTime) {
      return GetStartedScreen(onFinished: markAsNotFirstTime);
    } else {
      final session = supabase.auth.currentSession;
      if (session != null) {
        return const HomeScreen();
      } else {
        return const AuthScreen();
      }
    }
  }
}
