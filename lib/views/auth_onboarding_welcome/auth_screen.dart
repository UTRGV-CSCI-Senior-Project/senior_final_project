import 'package:flutter/material.dart';
import 'package:folio/constants/error_constants.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/repositories/user_repository.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:folio/views/home/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _scrollController = ScrollController();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late bool _isLogin;
  late UserRepository userRepository;
  bool _isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    _isLogin = widget.isLogin;

    _usernameFocusNode.addListener(() => _scrollToFocused(_usernameFocusNode));
_emailFocusNode.addListener(() => _scrollToFocused(_emailFocusNode));
_passwordFocusNode.addListener(() => _scrollToFocused(_usernameFocusNode));
    super.initState();
  }

  void _scrollToFocused(FocusNode focusNode){
    if (focusNode.hasFocus) {
      _scrollController.animateTo(
        150.0, // Adjust this value based on your UI layout
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios,
                size: 28)),
        toolbarHeight: 60,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Padding(padding: EdgeInsets.only(right: 12)),
                   Text(
                    "Folio",
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
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
                }, context, _usernameFocusNode),
              inputField('email-field', 'Email', 'Enter your email',
                  TextInputType.emailAddress, _emailController, (value) {
                setState(() {
                  errorMessage = "";
                });
              }, context, _emailFocusNode),
              inputField('password-field', 'Password', 'Enter your password',
                  TextInputType.text, _passwordController, (value) {
                setState(() {
                  errorMessage = "";
                });
              }, context, _passwordFocusNode, isPassword: true),
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
                  
                  child: _isLoading
                      ?  SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 5,
                          ),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Sign Up',
                          style:  GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: RichText(
                      text: TextSpan(
                          text: _isLogin
                              ? "Don't have an account?  "
                              : "Already have an account?  ",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: Theme.of(context).textTheme.bodyLarge?.color
                             ),
                          children: [
                        TextSpan(
                            text: _isLogin ? "Sign Up" : "Sign In",
                            style:  GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.primary))
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
