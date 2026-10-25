import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/controllers/exam_controller.dart';
import 'presentation/screens/home_tablet_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UnedInfantilApp());
}

class UnedInfantilApp extends StatelessWidget {
  const UnedInfantilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExamController()),
      ],
      child: MaterialApp(
        title: 'UNED Infantil Test (Tablet)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeTabletScreen(),
      ),
    );
  }
}
