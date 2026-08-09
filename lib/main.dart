import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/contributor_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/main/main_navigation_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OnamFundApp());
}

class OnamFundApp extends StatelessWidget {
  const OnamFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ContributorProvider>(
          create: (_) => ContributorProvider(),
          update: (_, auth, contributorProvider) {
            final provider = contributorProvider ?? ContributorProvider();
            if (auth.isLoggedIn) {
              provider.initDataStream();
            } else {
              provider.clearDataOnLogout();
            }
            return provider;
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return MaterialApp(
            title: 'Onam Fund Contribution Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: auth.isLoggedIn ? const MainNavigationView() : const LoginView(),
          );
        },
      ),
    );
  }
}
