import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'datasources/local_storage.dart';
import 'providers/gallery_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = LocalStorageService();
  await storageService.init();

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final LocalStorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GalleryProvider(storageService),
        ),
      ],
      child: MaterialApp(
        title: 'Albumix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: SplashScreen(storageService: storageService),
      ),
    );
  }
}
