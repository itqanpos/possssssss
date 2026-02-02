import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/sale/sale_bloc.dart';
import 'blocs/visit/visit_bloc.dart';
import 'repositories/auth_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/sale_repository.dart';
import 'repositories/visit_repository.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize services
  final localStorage = LocalStorageService();
  await localStorage.init();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final locationService = LocationService();

  final apiService = ApiService(localStorage: localStorage);

  runApp(MyApp(
    apiService: apiService,
    localStorage: localStorage,
    locationService: locationService,
    notificationService: notificationService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final LocalStorageService localStorage;
  final LocationService locationService;
  final NotificationService notificationService;

  const MyApp({
    Key? key,
    required this.apiService,
    required this.localStorage,
    required this.locationService,
    required this.notificationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(
            apiService: apiService,
            localStorage: localStorage,
          ),
        ),
        RepositoryProvider(
          create: (context) => CustomerRepository(
            apiService: apiService,
          ),
        ),
        RepositoryProvider(
          create: (context) => SaleRepository(
            apiService: apiService,
          ),
        ),
        RepositoryProvider(
          create: (context) => VisitRepository(
            apiService: apiService,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              localStorage: localStorage,
            )..add(const AppStarted()),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(
              apiService: apiService,
            ),
          ),
          BlocProvider(
            create: (context) => CustomerBloc(
              customerRepository: context.read<CustomerRepository>(),
              localStorage: localStorage,
            ),
          ),
          BlocProvider(
            create: (context) => SaleBloc(
              saleRepository: context.read<SaleRepository>(),
              localStorage: localStorage,
            ),
          ),
          BlocProvider(
            create: (context) => VisitBloc(
              visitRepository: context.read<VisitRepository>(),
              localStorage: localStorage,
              locationService: locationService,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'ERP - مندوب المبيعات',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            fontFamily: 'Cairo',
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthInitial || state is AuthLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is AuthAuthenticated) {
                return const MainScreen();
              }

              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
