import 'package:alla_zogak_vendor/models/vendors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alla_zogak_vendor/api/category_service.dart';
import 'package:alla_zogak_vendor/models/categories.dart';
import 'package:alla_zogak_vendor/widgets/add_product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/response_model.dart';
import '../widgets/bottom_Item.dart';
import '../widgets/category_card.dart';
import '../widgets/custom_animated_bottombar.dart';
import 'my_orders.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  static const _inactiveColor = Colors.grey;

  Widget getBody() {
    List<Widget> pages = [
      const HomeScreen(),
      const MyOrder(),
      const MyProfile(),
    ];
    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        title: Image.asset(
          "assets/logo.png",
          width: 45,
        ),
        centerTitle: true,
      ),
      body: getBody(),
      bottomNavigationBar: CustomAnimatedBottomBar(
        containerHeight: 70,
        backgroundColor: Colors.white,
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(
              Icons.home,
              color: _currentIndex == 0 ? Colors.black : Colors.grey,
            ),
            title: const Text(
              'الرئيسية',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(
              Icons.shopping_bag,
              color: _currentIndex == 1 ? Colors.black : Colors.grey,
            ),
            title: const Text(
              'الطلبات',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(
              Icons.person,
              color: _currentIndex == 2 ? Colors.black : Colors.grey,
            ),
            title: const Text(
              'البروفايل',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  barrierDismissible: true,
                  useRootNavigator: true,
                  barrierColor: Theme.of(context).primaryColor,
                  builder: (context) => const AddProductWidget(),
                );
              },
              child: const Icon(Icons.add),
            )
          : const Text(''),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey builderKey = GlobalKey();
  List<Categories> _categorieList = [];
  late Future<void> _initCategoriesData;
  @override
  void initState() {
    super.initState();
    _initCategoriesData = _initOrders();
  }

  Future<void> _initOrders() async {
    ResponseModel categories = await getMyCategories();
    _categorieList = List.generate(
        categories.data.length, (i) => Categories.fromJson(categories.data[i]));
  }

  Future<void> _refreshMyCategories() async {
    ResponseModel categories = await getMyCategories();
    setState(() {
      _categorieList = List.generate(categories.data.length,
          (i) => Categories.fromJson(categories.data[i]));
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
            future: _initCategoriesData,
            key: builderKey,
            builder: (c, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  {
                    return const Center(child: CircularProgressIndicator());
                  }
                case ConnectionState.done:
                  {
                    if (_categorieList.isEmpty) {
                      return const Center(
                        child: Text("You did not add any products"),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => _refreshMyCategories(),
                      child: ListView.builder(
                          itemCount: _categorieList.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CategoryCard(category: _categorieList[i]),
                            );
                          }),
                    );
                  }
              }
            }),
      ),
    );
  }
}

//For removing Scroll Glow
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
