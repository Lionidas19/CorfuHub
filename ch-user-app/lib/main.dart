import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corfu_shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_notifier.dart';
import 'features/map/map_notifier.dart';
import 'features/issues/issues_notifier.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'http://127.0.0.1:54331',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
);
const _env = String.fromEnvironment('ENV', defaultValue: 'local');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  final client = Supabase.instance.client;

  final repository = AppRepositoryImpl(
    supabase: SupabaseDataSource(client),
    cache: CacheDataSource(),
    mock: MockDataSource(),
    logger: ErrorLoggingService(
      client: client,
      sourceProject: 'corfu_hub_app',
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AppRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => MapNotifier(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => IssuesNotifier(repository),
        ),
      ],
      child: EnvBanner(
        environment: EnvironmentEnum.fromValue(_env),
        child: const CorfuHubApp(),
      ),
    ),
  );
}

class CorfuHubApp extends StatefulWidget {
  const CorfuHubApp({super.key});

  @override
  State<CorfuHubApp> createState() => _CorfuHubAppState();
}

class _CorfuHubAppState extends State<CorfuHubApp> {
  late final _router = buildRouter(context.read<AuthNotifier>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CorfuHub',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
