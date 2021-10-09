import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'products.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  var title = '';
  var desc = '';
  var price = '';
  var imageUrl = '';
  late FToast fToast;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  _showToast(String ms) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("$ms"),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
    // Custom Toast Position
    /*  fToast.showToast(
        child: toast,
        toastDuration: const Duration(seconds: 2),
  positionedToastBuilder: (context, child) {
  return Positioned(
  child: child,
  top: 16.0,
  left: 16.0,
  );
  });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => title = val),
                    decoration: const InputDecoration(
                        labelText: "Title", hintText: "Add title"),
                  ),
                  TextField(
                    onChanged: (val) => setState(() => desc = val),
                    decoration: const InputDecoration(
                        labelText: "Description", hintText: "Add description"),
                  ),
                  TextField(
                    onChanged: (val) => setState(() => price = val),
                    decoration: const InputDecoration(
                        labelText: "Price", hintText: "Add price"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) => setState(() => imageUrl = val),
                    decoration: const InputDecoration(
                        labelText: "Image Url",
                        hintText: "Paste your image url here"),
                  ),
                  const SizedBox(height: 30),
                  Consumer<Products>(
                    builder: (ctx, value, _) =>
                        // ignore: deprecated_member_use
                        RaisedButton(
                      color: Colors.orangeAccent,
                      textColor: Colors.black,
                      child: const Text("Add Product"),
                      onPressed: () async {
                        double? doublePrice;
                        setState(() {
                          doublePrice = double.tryParse(price) ?? 0.0;
                        });
                        if (title == '' ||
                            desc == '' ||
                            price == '' ||
                            imageUrl == '') {
                          _showToast("Please enter all Fields");
                          /*Toast.show("Please enter all Fields", ctx,
                        duration: Toast.LENGTH_LONG);*/
                        } else if (doublePrice == 0.0) {
                          _showToast("Please enter a valid price");
                          /*Toast.show("Please enter a valid price", ctx,
                          duration: Toast.LENGTH_LONG);*/
                        } else {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            await value.add(
                              id: DateTime.now().toString(),
                              title: title,
                              description: desc,
                              price: doublePrice,
                              imageUrl: imageUrl,
                            );
                          } catch (_) {
                            showDialog<void>(
                                context: context,
                                builder: (innerContext) => AlertDialog(
                                      title: const Text('An error occurred !'),
                                      content: const Text('Something wrong.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(innerContext)
                                                    .pop(),
                                            child: const Text('Okay'))
                                      ],
                                    ));
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });

                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
