import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_trickbd/tabs/browse_tab.dart';
import 'package:neo_trickbd/tabs/posts_tab.dart';

import 'main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tabIndex = 0;
  late PageController tabController;

  final tabs = [
    const PostsTab(),
    const SizedBox(),
    const BrowseTab(),
  ];

  @override
  void initState() {
    super.initState();
    tabController = PageController(initialPage: tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          systemNavigationBarIconBrightness:
              isDarkTheme(context) ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Theme.of(context).colorScheme.surface),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constrains) => Scaffold(
            appBar: AppBar(
              title: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
                width: 120,
              ),
              centerTitle: true,
            ),
            bottomNavigationBar: constrains.maxWidth > widthBreakpoint
                ? null
                : NavigationBar(
                    elevation: 0,
                    onDestinationSelected: (value) => setState(() {
                      tabIndex = value;
                      tabController.jumpToPage(value);
                    }),
                    selectedIndex: tabIndex,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.view_list_rounded),
                        selectedIcon: Icon(Icons.view_list_outlined),
                        label: "Recent",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.manage_search_rounded),
                        label: "Search",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded),
                        label: "Browse",
                      )
                    ],
                  ),
            body: Row(
              children: [
                if (constrains.maxWidth > widthBreakpoint)
                  NavigationRail(
                    onDestinationSelected: (value) => setState(() {
                      tabIndex = value;
                      tabController.jumpToPage(value);
                    }),
                    selectedIndex: tabIndex,
                    labelType: constrains.maxWidth > widthBreakpoint * 2
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    extended: constrains.maxWidth > widthBreakpoint * 2,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.view_list_rounded),
                        selectedIcon: Icon(Icons.view_list_outlined),
                        label: Text("Recent"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.manage_search_rounded),
                        label: Text("Search"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded),
                        label: Text("Browse"),
                      )
                    ],
                  ),
                Expanded(
                  child: PageView(
                    controller: tabController,
                    children: tabs,
                    onPageChanged: (value) => setState(() => tabIndex = value),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
