//File just to navigate to after successful sign/log in
//Can be changed
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/welcome_screen.dart';
import 'package:folio/core/user_location_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double Phonewidth = MediaQuery.sizeOf(context).width;
    double Phoneheight = MediaQuery.sizeOf(context).height;
    Future<String> userAddress = currentAddress();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Welcome USER ",
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ), //change this to users name,
          )),
      body: ListView(children: [
        Column(
          children: [
            Container(
              //this part still needs work not done

              width: Phonewidth - 10,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Prefences",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(
                        width: 150,
                      ),
                      TextButton(
                        key: Key("Edit_Proffesion_Key"),
                        onPressed: () {},
                        child: const Text(
                          "Edit",
                          style:
                              TextStyle(color: Color.fromRGBO(0, 111, 253, 1)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 30,
                      child: CarouselView(
                        itemExtent: 140,
                        children: List.generate(
                          10,
                          (int index) {
                            return ElevatedButton(
                                key: Key("Proffesion_button_$index "),
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll<Color>(
                                          Color.fromRGBO(234, 242, 255, 1)),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  "Proffesional",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(0, 111, 253, 1)),
                                ));
                          },
                        ),
                      ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Near You",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 150,
                ),
                TextButton(
                  key: Key("See_more_button"),
                  onPressed: () {},
                  child: const Text(
                    "See more",
                    style: TextStyle(color: Color.fromRGBO(0, 111, 253, 1)),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 245,
              child: CarouselView(
                  itemExtent: 250,
                  itemSnapping: true,
                  children: List.generate(10, (int index) {
                    return Container(
                      key: Key("Near_You_Recommendation_Button_$index "),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Image.asset(
                            "assets/Explore.png",
                            width: 250,
                            height: 245,
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "First Last ",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Proffesion",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  })),
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Recently Viewed",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                  ),
                ]),
            SizedBox(
              height: 360,
              child: CarouselView(
                  scrollDirection: Axis.vertical,
                  itemExtent: 70,
                  itemSnapping: true,
                  children: List.generate(2, (int index) {
                    return Row(
                      key: Key("Recenty_View_Button_$index "),
                      children: [
                        Image.asset(
                          "assets/Explore.png",
                          width: 80,
                        ),
                        const Column(children: [
                          Text(
                            "First Last ",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Proffesion",
                            style: TextStyle(fontSize: 12),
                          ),
                        ]),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    );
                  })),
            )
          ],
        )
      ]),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
