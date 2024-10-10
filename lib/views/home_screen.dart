//File just to navigate to after successful sign/log in
//Can be changed
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double Phonewidth = MediaQuery.sizeOf(context).width;
    double Phoneheight = MediaQuery.sizeOf(context).height;
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
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            //this part still needs work not done
            height: 50,
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
                    TextButton(onPressed: () {}, child: Text("Edit"))
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (int index) {
                      return SizedBox(
                          height: 24,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors
                                    .blueGrey), //change this ugly color to  EAF2FF
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Proffesional",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              )));
                    },
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Near You"),
              const SizedBox(
                width: 150,
              ),
              TextButton(onPressed: () {}, child: Text("See more"))
            ],
          ),
          SizedBox(
            height: 245,
            child: CarouselView(
                itemExtent: 250,
                itemSnapping: true,
                children: List.generate(10, (int index) {
                  return Container(
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
              ]),
          SizedBox(
            height: 360,
            child: CarouselView(
                scrollDirection: Axis.vertical,
                itemExtent: 70,
                itemSnapping: true,
                children: List.generate(2, (int index) {
                  return Row(
                    children: [
                      Image.asset(
                        "assets/Explore.png",
                        width: 80,
                      ),
                      Column(children: [
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
                      Spacer(),
                      Icon(Icons.arrow_forward_ios_sharp)
                    ],
                  );
                })),
          )
        ],
      )),
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
