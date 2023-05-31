import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tea_commerce/services/users_service.dart';

class Auth extends StatefulWidget {
  const Auth({ super.key });

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage; // currently unused
  bool _isSignup = false;
  bool _isSeller = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signup() async {
    final String username = _usernameController.value.toString();
    final String email = _emailController.value.toString();
    final String password = _passwordController.value.toString();

    if (username.isEmpty || email.isEmpty || password.isEmpty) return;

    final UsersServiceResponse response = await context.read<UsersService>().signup(
      username: username,
      email: email,
      password: password,
      isSeller: _isSeller,
    );

    if (!response.successful) setState(() => _errorMessage = response.errorMessage);

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("auth_token", response.data);
  }

  Future<void> _login() async {
    final String email = _emailController.value.toString();
    final String password = _passwordController.value.toString();

    if (email.isEmpty || password.isEmpty) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    bottom: 50
                  ),
                  child: Text(_isSignup ? "Signup" : "Login",
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Visibility(
                      visible: _isSignup,
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                          label: Text("Username"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                          label: Text("Email")
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                          label: Text("Password")
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _isSignup,
                      child: Row(
                        children: <Widget>[
                          const Text(" I am a ",
                            style: TextStyle(
                              fontSize: 18
                            ),
                          ),
                          DropdownButton<String>(
                            value: _isSeller ? "Seller" : "Buyer",
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            onChanged: (String? value) => setState(() => _isSeller = value == "Seller"),
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem<String>(
                                value: "Buyer",
                                child: Text("Buyer"),
                              ),
                              DropdownMenuItem<String>(
                                value: "Seller",
                                child: Text("Seller"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(_isSignup ? "Already have an account? " : "Don't have an account?"),
                        TextButton(
                          onPressed: () => setState(() => _isSignup = !_isSignup),
                          child: Text(_isSignup ? "Login" : "Signup"),
                        ),
                      ],
                    ),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: ElevatedButton(
                        onPressed: _isSignup ? _signup : _login,
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                          padding: MaterialStatePropertyAll(EdgeInsets.all(12))
                        ),
                        child: Text(_isSignup ? "Signup" : "Login",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}
