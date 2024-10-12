import 'package:flutter/material.dart';
import 'package:folio/views/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        shrinkWrap: true,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "FOLIO",
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                ),
                ),
              Image.asset("assets/Explore.png",width: 250,height: 250,),
              const Text("Discover Local Talent,",style: tempTextstlye.customTextstyle,),
              const Text("Book with Ease ",style: tempTextstlye.customTextstyle,),
              //const Text("App Name",style: tempTextstlye.customTextstyle,),
              const SizedBox(height: 100,),
              
              Container(
                width: screenWidth - 40,
                height: 60,
                decoration: BoxDecoration(
                    color:  const Color.fromRGBO(0, 111, 253, 1),
                    border: Border.all(
                      color: const Color.fromRGBO(0, 111, 253, 1),
                      width: 3,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: TextButton(
                  key: const Key('login-button'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen(
                                    isLogin: true,
                                  )));
                    },
                    child: const Text('Login',
                    style: tempTextstlye.customButtonTextstyle,)),
              ), 
              const SizedBox(height: 20,),
              Container(
                  width: screenWidth - 40,
                  decoration: BoxDecoration(
                    color:  const Color.fromRGBO(0, 111, 253, 1),
                    border: Border.all(
                      color:  const Color.fromRGBO(0, 111, 253, 1),
                        width: 3,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Consumer(builder: (context, ref, child) {
                    return TextButton(
                        key: const Key('signup-button'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen(
                                        isLogin: false,
                                      )));
                        },
                        child: const Text(
                          'Sign up',
                          style: tempTextstlye.customButtonTextstyle,
                          )
                        );
                  }))
            ],
          )
        ],
      ),
    );
  }
}
class tempTextstlye{
   static const customTextstyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      
      );
   static const customButtonTextstyle = TextStyle(
      fontSize: 20,
      color: Colors.white,
      );
}