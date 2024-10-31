import 'package:flutter/material.dart';
import 'package:folio/views/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Image.asset("assets/Explore.png",width: 250,height: 250,color: Theme.of(context).colorScheme.primary,),
              const SizedBox(height: 50,),
              Text("Discover Local Talent,",style: TempTextStyle.customTextstyle,),
               Text("Book with Ease ",style: TempTextStyle.customTextstyle,),
              //const Text("App Name",style: TempTextStyle.customTextstyle,),
              const SizedBox(height: 50,),
              
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                    color:  Theme.of(context).colorScheme.primary,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
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
                    child:  Text('Login',
                    style: TempTextStyle.customButtonTextstyle,)),
              ), 
              const SizedBox(height: 20,),
              Container(
                width: double.infinity,
                  decoration: BoxDecoration(
                    color:  Theme.of(context).colorScheme.primary,
                    border: Border.all(
                      color:  Theme.of(context).colorScheme.primary,
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
                        child:  Text(
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
   static  TextStyle customTextstyle = GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      
      );
   static TextStyle customButtonTextstyle = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold
   );
   

}