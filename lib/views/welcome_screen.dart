import 'package:flutter/material.dart';
import 'package:folio/views/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "FOLIO",
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                ),
                ),
              Image.asset("assets/Explore.png",width: 250,height: 250,color: const Color.fromRGBO(0, 111, 253, 1),),
              const SizedBox(height: 50,),
              const Text("Discover Local Talent,",style: TempTextStyle.customTextstyle,),
              const Text("Book with Ease ",style: TempTextStyle.customTextstyle,),
              //const Text("App Name",style: TempTextStyle.customTextstyle,),
              const SizedBox(height: 50,),
              
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                    color:  const Color.fromRGBO(0, 111, 253, 1),
                    border: Border.all(
                      color: const Color.fromRGBO(0, 111, 253, 1),
                      width: 3,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: TextButton(
                  key: const Key('signin-button'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen(
                                    isLogin: true,
                                  )));
                    },
                    child: const Text('Login',
                    style: TempTextStyle.customButtonTextstyle,)),
              ), 
              const SizedBox(height: 20,),
              Container(
                width: double.infinity,
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
                          style: TempTextStyle.customButtonTextstyle,
                          )
                        );
                  }))
            ],
          )),
      ))
      
    );
  }
}
class TempTextStyle{
   static const customTextstyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      
      );
   static const customButtonTextstyle = TextStyle(
      fontSize: 20,
      color: Colors.white,
      );
}