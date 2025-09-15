import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// ⬇️ Importa tu tema
import 'themes/theme.dart';

// ViewModels
import 'viewmodels/usuario_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/historial_viewmodel.dart';
import 'viewmodels/crear_solicitud_viewmodel.dart';
import 'viewmodels/aprobar_solicitudes_viewmodel.dart';
import 'viewmodels/detalle_nomina_viewmodel.dart';
import 'viewmodels/dias_descanso_viewmodel.dart';
import 'viewmodels/crear_solicitud_descanso_viewmodel.dart';
import 'viewmodels/historial_descanso_viewmodel.dart';
import 'viewmodels/asistencia_viewmodel.dart';
import 'viewmodels/nominas_globales_viewmodel.dart';
import 'pages/nominas_globales_view.dart';
import 'viewmodels/registrar_empleado_viewmodel.dart';

// Pages / Views
import 'pages/login_view.dart';
import 'pages/home_view.dart';
import 'pages/historial_view.dart';
import 'pages/detalle_solicitud_view.dart';
import 'pages/crear_solicitud_view.dart';
import 'pages/aprobar_solicitudes_view.dart';
import 'pages/aprobar_detalle_view.dart';
import 'pages/detalle_nomina_view.dart';
import 'pages/dias_descanso_view.dart';
import 'pages/crear_solicitud_descanso_view.dart';
import 'pages/historial_descanso_view.dart';
import 'pages/asistencia_view.dart';
import 'pages/registrar_empleado_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => HistorialViewModel()),
        ChangeNotifierProvider(create: (_) => CrearSolicitudViewModel()),
        ChangeNotifierProvider(create: (_) => AprobarSolicitudesViewModel()),
        ChangeNotifierProvider(create: (_) => DetalleNominaViewModel()),
        ChangeNotifierProvider(create: (_) => DiasDescansoViewModel()),
        ChangeNotifierProvider(create: (_) => CrearSolicitudDescansoViewModel()),
        ChangeNotifierProvider(create: (_) => HistorialDescansoViewModel()),
        ChangeNotifierProvider(create: (_) => AsistenciaViewModel()),
        ChangeNotifierProvider(create: (_) => RegistrarEmpleadoViewModel()),
        ChangeNotifierProvider(create: (_) => NominasGlobalesViewModel()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NominApp',
        // ⬇️ Aplica el tema global de la marca
        theme: AppTheme.lightTheme,
        // (opcional) si luego agregamos dark:
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.system,

        initialRoute: '/',
        routes: {
          '/': (_) => const LoginView(),
          '/homeEmpleado': (_) => const HomeView(),
          '/homeCajero': (_) => const HomeView(),
          '/homeAdmin': (_) => const HomeView(),
          '/historial': (_) => const HistorialView(),
          '/detalleSolicitud': (_) => const DetalleSolicitudView(),
          '/crearSolicitud': (_) => const CrearSolicitudView(),
          '/aprobarSolicitudes': (_) => const AprobarSolicitudesView(),
          '/aprobarDetalle': (_) => const AprobarDetalleView(),
          '/detalleNomina': (_) => const DetalleNominaView(),
          '/diasDescanso': (_) => const DiasDescansoView(),
          '/crearSolicitudDescanso': (_) => const CrearSolicitudDescansoView(),
          '/historialDescanso': (_) => const HistorialDescansoView(),
          '/asistencia': (_) => const AsistenciaView(),
          '/registrarEmpleado': (_) => const RegistrarEmpleadoView(),
          '/nominasGlobales': (_) => const NominasGlobalesView(),

        },
      ),
    );
  }
}
