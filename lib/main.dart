import 'package:alla_zogak_vendor/screens/order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alla_zogak_vendor/screens/home_page.dart';
import 'package:alla_zogak_vendor/screens/login.dart';
import 'package:alla_zogak_vendor/screens/product_screen.dart';
import 'models/products.dart';
import 'screens/Landing/splash.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Digital Mall',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        textTheme: const TextTheme(
          headline1: TextStyle(color: Colors.black54),
          headline2: TextStyle(color: Colors.black54),
          headline3: TextStyle(color: Colors.black54),
          headline4: TextStyle(color: Colors.black54),
          headline5: TextStyle(color: Colors.black54),
          headline6: TextStyle(color: Colors.black54),
          subtitle1: TextStyle(color: Colors.black54),
          subtitle2: TextStyle(color: Colors.black54),
        ),
        iconTheme: const IconThemeData(
          color: Colors.grey,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black,
          )
        )
      ),
      initialRoute: "splash",
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "splash":
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case "login":
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case "home":
            return MaterialPageRoute(builder: (_) => const HomePage());
          case "product":
            return MaterialPageRoute(
              builder: (_) => ProductSc(
                product: settings.arguments as Products,
              ),
            );
          case "orderDetails":
            return MaterialPageRoute(
              builder: (_) => OrderDetails(
                id: settings.arguments as int,
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
      locale: const Locale("ar", "SA"),
      supportedLocales: const [Locale("ar", "SA")],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
