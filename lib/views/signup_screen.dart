import 'package:flutter/material.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/widgets/snackbar_widget.dart';
import 'package:senior_final_project/views/home_screen.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key, required this.userRepository});

  final UserRepository userRepository;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset('assets/Explore.png'),
                  const Padding(padding: EdgeInsets.only(right: 12)),
                  const Text(
                    "App Name",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(
                height: 75,
              ),
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 25,
              ),
              _inputField('username-field','Username', 'Enter your unique username',
                  TextInputType.text, _usernameController),
              _inputField('email-field','Email', 'Enter your email',
                  TextInputType.emailAddress, _emailController),
              _inputField('password-field','Password', 'Enter your password', TextInputType.text,
                  _passwordController,
                  isPassword: true),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  key: const Key('signup-button'),
                  onPressed: () async {
                    if(_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty){
                      showCustomSnackBar(context, 'empty-fields');
                    }else{

                    try {
                      await userRepository.createUser(
                          _usernameController.text,
                          _emailController.text,
                          _passwordController.text);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    } catch (e) {
                      showCustomSnackBar(context, e.toString());
                    }}
                  },
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                      backgroundColor: const Color.fromARGB(255, 0, 111, 253),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: RichText(
                      text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black),
                          children: [
                        TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
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
}

Widget _inputField(String key, String label, String hintText, TextInputType keyboardType,
    TextEditingController controller,
    {bool isPassword = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const Padding(padding: EdgeInsets.only(bottom: 5)),
      TextField(
        key: Key(key),
        controller: controller,
        cursorColor: const Color.fromARGB(255, 0, 111, 253),
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 0, 111, 253), width: 2.3)),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 104, 97, 97), width: 2)),
        ),
      ),
    ]),
  );
}
