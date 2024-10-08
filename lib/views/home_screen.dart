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
            "Welcome USER ", //change this to users name,
          )),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            height: 50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Prefences"),
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
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.blueGrey),
                              ),
                              onPressed: () {},
                              child: const Text("Proffesional")));
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
                    color: Colors.blueAccent,
                  );
                })),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            const Text(
              "Recently Viewed",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 150,
            ),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.arrow_forward_sharp)),
          ]),
          SizedBox(
            height: 245,
            child: CarouselView(
                scrollDirection: Axis.vertical,
                itemExtent: 50,
                itemSnapping: true,
                children: List.generate(10, (int index) {
                  return Container(
                    color: Colors.blueAccent,
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
