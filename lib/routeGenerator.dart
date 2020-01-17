import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_control/detalhes.dart';
import 'package:my_control/selecionarConta.dart';

import 'main.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => MyHomePage());
      case "/detalhes":
        if (args is DocumentSnapshot) {
          return MaterialPageRoute(builder: (_) => DetalhesPage(args));
        }
        return _errorRoute();
      case "/selecionarConta":
        if (args is ArgumentosTelaSelecionar) {
          return MaterialPageRoute(
              builder: (_) => SelecionarContaPage(ats: args));
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Falha ao navegar"),
        ),
        body: Center(
          child: Text("Error"),
        ),
      );
    });
  }
}
