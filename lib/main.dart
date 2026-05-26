import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/appointments/appointment_provider.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  // 1. Asegura la comunicación con el motor de Flutter (Requerido para Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase con las opciones de la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Inicializa el servicio de Notificaciones (FCM)
  final fcmService = FcmService();
  await fcmService.initialize();

  // 4. Lanza la app envolviéndola en el Provider para tus citas
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppointmentProvider(),
      child: const ClinicApp(),
    ),
  );
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      home: const AuthGate(),
    );
  }
}