import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corfu_shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final supabaseSource = SupabaseDataSource(client);
  final cacheSource = CacheDataSource();
  final mockSource = MockDataSource();
  final logger = ErrorLoggingService(
    client: client,
    sourceProject: 'corfu_hub_app',
  );

  final repository = AppRepositoryImpl(
    supabase: supabaseSource,
    cache: cacheSource,
    mock: mockSource,
    logger: logger,
  );

  runApp(
    Provider<AppRepository>.value(
      value: repository,
      child: EnvBanner(
        environment: EnvironmentEnum.fromValue(_env),
        child: const CorfuHubApp(),
      ),
    ),
  );
}

class CorfuHubApp extends StatelessWidget {
  const CorfuHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CorfuHub',
      home: Scaffold(
        body: Center(child: Text('Resident App — Coming Soon')),
      ),
    );
  }
}

