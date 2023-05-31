import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "package:tea_commerce/models/user_model.dart";
import "package:tea_commerce/routes.dart";
import "package:tea_commerce/services/users_service.dart";

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({ super.key });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UsersService>(create: (_) => UsersService())
      ],
      builder: (_, __) => const StateWrapper(),
    );
  }
}

class StateWrapper extends StatefulWidget {
  const StateWrapper({ super.key });

  @override
  State<StateWrapper> createState() => _StateWrapperState();
}

class _StateWrapperState extends State<StateWrapper> {
  String _initialRoute = "/";

  Future<void> checkUser() async {
    final UserModel? user = await context.read<UsersService>().user;

    if (user == null) _initialRoute = "/";
  } 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tea Commerce",
      routes: routes,
      initialRoute: _initialRoute,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme()
      ),
    );
  }
}