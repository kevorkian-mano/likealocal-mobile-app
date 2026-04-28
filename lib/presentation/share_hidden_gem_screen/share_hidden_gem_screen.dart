import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../explore_page_with_notif_screen/explore_page_with_notif_screen.dart';
import '../maps_page/maps_page.dart';
import '../user_profile_page/user_profile_page.dart';
import './provider/share_hidden_gem_provider.dart';
import './share_hidden_gem_initial_page.dart';

class ShareHiddenGemScreen extends StatefulWidget {
  const ShareHiddenGemScreen({Key? key}) : super(key: key);

  @override
  ShareHiddenGemScreenState createState() => ShareHiddenGemScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShareHiddenGemProvider(),
      child: ShareHiddenGemScreen(),
    );
  }
}

class ShareHiddenGemScreenState extends State<ShareHiddenGemScreen> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Navigator(
          key: navigatorKey,
          initialRoute: AppRoutes.explorePageWithNotifScreen,
          onGenerateRoute: (routeSetting) => PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) =>
                getCurrentPage(context, routeSetting.name!),
            transitionDuration: Duration(seconds: 0),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.maxFinite,
        child: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    var bottomBarItemList = <CustomBottomBarItem>[
      CustomBottomBarItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        title: 'Explore',
        routeName: AppRoutes.explorePageWithNotifScreen,
      ),
      CustomBottomBarItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        title: 'Map',
        routeName: AppRoutes.mapsPage,
      ),
      CustomBottomBarItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        title: 'Add',
        routeName: AppRoutes.shareHiddenGemScreenInitialPage,
      ),
      CustomBottomBarItem(
        icon: Icons.smart_toy_outlined,
        activeIcon: Icons.smart_toy,
        title: 'Guide',
        routeName: AppRoutes.shareHiddenGemScreenInitialPage,
      ),
      CustomBottomBarItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        title: 'Profile',
        routeName: AppRoutes.userProfilePage,
      ),
    ];

    return CustomBottomBar(
      bottomBarItemList: bottomBarItemList,
      onChanged: (index) {
        if (index == 2) {
          // If the middle tab (Add) is tapped, show it as a modal bottom sheet
          var provider = Provider.of<ShareHiddenGemProvider>(context, listen: false);
          showModalBottomSheet(
            context: Navigator.of(context, rootNavigator: true).context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) {
              return ChangeNotifierProvider<ShareHiddenGemProvider>.value(
                value: provider,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: ShareHiddenGemInitialPage.builder(context)
                ),
              );
            },
          );
          return;
        }

        setState(() {
          _selectedIndex = index;
        });
        var bottomBarItem = bottomBarItemList[index];
        navigatorKey.currentState?.pushReplacementNamed(bottomBarItem.routeName);
      },
      selectedIndex: _selectedIndex,
    );
  }

  Widget getCurrentPage(BuildContext context, String currentRoute) {
    switch (currentRoute) {
      case AppRoutes.shareHiddenGemScreenInitialPage:
        return ShareHiddenGemInitialPage.builder(context);
      case AppRoutes.explorePageWithNotifScreen:
        return ExplorePageWithNotifScreen.builder(context);
      case AppRoutes.mapsPage:
        return MapsPage.builder(context);
      case AppRoutes.userProfilePage:
        return const UserProfilePage();
      default:
        return Container();
    }
  }
}
