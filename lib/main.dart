
import 'package:flutter/material.dart';
import 'asignada.page.dart';
import 'myhome.page.dart';
import 'services/locator.service.dart'as lo;
import 'services/navigation.service.dart';
import 'login.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  lo.setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'PMRApp',
      navigatorKey: lo.locator<NavigationService>().navigatorKey,
      onGenerateRoute: (routeSettings) {
        switch(routeSettings.name){
          case 'home': return MaterialPageRoute(builder: (context) => MyHomePage(title: "Home",));
          case 'solicitudes': return MaterialPageRoute(builder: (context) => SolicitudesPage());
          default: return MaterialPageRoute(builder: (context) => LoginPage());
        }
      },
      home: LoginPage(title: 'Login Page',),
    ); 
  }
}
