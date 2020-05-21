
import 'package:flutter/material.dart';
import 'package:pmrapp/pages/asignada.page.dart';
import 'package:pmrapp/pages/login.page.dart';
import 'package:pmrapp/pages/myhome.page.dart';
import 'package:pmrapp/services/locator.service.dart'as lo;
import 'package:pmrapp/services/navigation.service.dart';

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
