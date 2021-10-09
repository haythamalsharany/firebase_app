import 'package:firebase_app/auth.dart';
import 'package:firebase_app/auth_screen.dart';
import 'package:firebase_app/splash.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_products.dart';
import 'auth.dart';
import 'product_details.dart';
import 'products.dart';

late SharedPreferences pref;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Auth>(
        create: (_) => Auth(),
      ),
      ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, value, prevProvider) => Products()
            ..update(
                pref.containsKey('token')
                    ? pref.getString('token')
                    : value.token,
                prevProvider != null ? prevProvider.productsList : []))
    ],
    child: const MyApp(
      key: Key("value"),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (ctx, value, _) => MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.orange,
            canvasColor: const Color.fromRGBO(255, 238, 219, 1)),
        debugShowCheckedModeBanner: false,
        home: value.isAuth
            ? const MyHomePage()
            : FutureBuilder(
                future:
                    Provider.of<Auth>(context, listen: false).tryAutoLogin(),
                builder: (ctx, snapshot) {
                  //  Fluttertoast.showToast(msg: "ggggg");

                  return snapshot.connectionState == ConnectionState.waiting
                      ? const SplashScreen()
                      : (pref.getString('token') != null &&
                              pref.getString('token') != '')
                          ? const MyHomePage()
                          : const AuthScreen();
                }),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<Products>(context, listen: true)
        .fetchData()
        .then((value) async {
      _isLoading = false;
      /*final SharedPreferences pref = await SharedPreferences.getInstance();
      Fluttertoast.showToast(msg: pref.getString('token')!);*/
    }).catchError((e) {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> prodList =
        Provider.of<Products>(context, listen: false).productsList;

    Widget detailCard(id, tile, desc, price, imageUrl, ctx) {
      // ignore: deprecated_member_use
      return FlatButton(
        onPressed: () {
          Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => ProductDetails(id)),
          ).then((id) {
            try {
              Provider.of<Products>(context, listen: false).delete(id);
            } catch (e) {
              Fluttertoast.showToast(
                  msg: "e.toString()", toastLength: Toast.LENGTH_LONG);
              print('''
===========================================================${e.toString()}=======================''');
            }
          });
        },
        child: Column(
          children: [
            const SizedBox(height: 5),
            Card(
              elevation: 10,
              color: const Color.fromRGBO(115, 138, 119, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      width: 130,
                      child: Hero(
                        tag: id,
                        child: Image.network(imageUrl, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Text(
                          tile,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.white),
                        // ignore: sized_box_for_whitespace
                        Container(
                          width: 200,
                          child: Text(
                            desc,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.justify,
                            maxLines: 3,
                          ),
                        ),
                        const Divider(color: Colors.white),
                        Text(
                          "\$$price",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                        const SizedBox(height: 13),
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Product'),
        actions: [
          IconButton(
            onPressed: () => Provider.of<Auth>(context, listen: false).logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : prodList.isEmpty
              ? const Center(
                  child: Text('No Products Added.',
                      style: TextStyle(fontSize: 22)))
              : RefreshIndicator(
                  onRefresh: () async =>
                      await Provider.of<Products>(context, listen: false)
                          .fetchData(),
                  child: ListView(
                    children: prodList
                        .map(
                          (item) => Builder(
                              builder: (ctx) => detailCard(
                                  item.id,
                                  item.title,
                                  item.description,
                                  item.price,
                                  item.imageUrl,
                                  ctx)),
                        )
                        .toList(),
                  ),
                ),
      floatingActionButton: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).primaryColor,
        ),
        // ignore: deprecated_member_use
        child: FlatButton.icon(
          label: const Text("Add Product",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddProduct())),
        ),
      ),
    );
  }
}
