import 'package:flutter/material.dart';
import 'package:tea_commerce/main_screens.dart';
import 'package:tea_commerce/screens/auth.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (BuildContext context) => const MainScreens(),
  '/auth': (BuildContext context) => const Auth(),
};
