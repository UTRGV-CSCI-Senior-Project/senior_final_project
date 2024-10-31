import 'package:flutter/material.dart';
import 'package:folio/constants/error_constants.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/repositories/user_repository.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:folio/views/home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, required this.isLogin});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLogin;
  late UserRepository userRepository;
  bool _isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    _isLogin = widget.isLogin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios,
                color: Color.fromARGB(255, 0, 111, 253), size: 28)),
        toolbarHeight: 60,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/Explore.png",
                    width: 45,
                    height: 45,
                    color: const Color.fromRGBO(0, 111, 253, 1),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 12)),
                  const Text(
                    "Folio",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              ErrorBox(
                  errorMessage: errorMessage,
                  onDismiss: () {
                    setState(() {
                      errorMessage = "";
                    });
                  }),
              const SizedBox(
                height: 25,
              ),
              Text(
                _isLogin ? "Sign In" : "Sign Up",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 25,
              ),
              if (!_isLogin)
                inputField(
                    'username-field',
                    'Username',
                    'Enter your unique username',
                    TextInputType.text,
                    _usernameController, (value) {
                  setState(() {
                    errorMessage = "";
                  });
                }),
              inputField('email-field', 'Email', 'Enter your email',
                  TextInputType.emailAddress, _emailController, (value) {
                setState(() {
                  errorMessage = "";
                });
              }),
              inputField('password-field', 'Password', 'Enter your password',
                  TextInputType.text, _passwordController, (value) {
                setState(() {
                  errorMessage = "";
                });
              }, isPassword: true),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  key: Key(_isLogin ? 'signin-button' : 'signup-button'),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            errorMessage = "";
                          });
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              !_isLogin && _usernameController.text.isEmpty) {
                            setState(() {
                              errorMessage =
                                  ErrorConstants.getMessage('empty-fields');
                            });
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            userRepository = ref.read(userRepositoryProvider);
                            try {
                              if (_isLogin) {
                                await userRepository.signIn(
                                    _emailController.text,
                                    _passwordController.text);
                                // Navigate to home screen or show success message
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                  );
                                }
                              } else {
                                await userRepository.createUser(
                                  _usernameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                  );
                                }
                              }
                            } catch (e) {
                              if (e is AppException) {
                                errorMessage = e.message;
                              } else {
                                errorMessage =
                                    "An unexpected error occurred. Please try again later or contact support if the problem persists.";
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                      backgroundColor: const Color.fromARGB(255, 0, 111, 253),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 5,
                          ),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: RichText(
                      text: TextSpan(
                          text: _isLogin
                              ? "Don't have an account?  "
                              : "Already have an account?  ",
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black),
                          children: [
                        TextSpan(
                            text: _isLogin ? "Sign Up" : "Sign In",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 111, 253)))
                      ])),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
