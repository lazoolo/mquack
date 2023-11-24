import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  CustomBottomNavigationBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: (currentIndex >= 0 && currentIndex <= 1) ? currentIndex : 0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Connections',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ],
      onTap: (index) {
        if (index != currentIndex) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/connections');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/messages');
              break;
          }
        }
      },
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final int currentIndex;
  final Widget body;

  const ResponsiveLayout({required this.currentIndex, required this.body});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout with temporary drawer
          return SafeArea(
              child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text('MQTT Connections'),
            ),
            drawer: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // Set the drawer width to 80% of the screen width
              child: Container(
                color: Colors.grey[200], // Change this to your desired color
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ListTile(
                      title: Text('Connections'),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/connections');
                      },
                    ),
                    ListTile(
                      title: Text('Messages'),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/messages');
                      },
                    ),
                    ListTile(
                      title: Text('Logs'),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/logs');
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              child: Align(
                alignment: Alignment.topCenter,
                child: body,
              ),
            ),
            bottomNavigationBar:
                CustomBottomNavigationBar(currentIndex: currentIndex),
          ));
        } else {
          // Desktop layout with permanent drawer
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text('MQTT Connections'),
            ),
            body: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color:
                        Colors.grey[200], // Change this to your desired color
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        ListTile(
                          title: Text('Connections'),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/connections');
                          },
                        ),
                        ListTile(
                          title: Text('Messages'),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/messages');
                          },
                        ),
                        ListTile(
                          title: Text('Logs'),
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/logs');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
