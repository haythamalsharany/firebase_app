// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'products.dart';

class ProductDetails extends StatelessWidget {
  final String id;

  const ProductDetails(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Product> prodList =
        Provider.of<Products>(context, listen: true).productsList;

    // ignore: null_check_always_fails
    final int prodIndex = prodList.indexWhere((element) => element.id == id);
    Product? filteredItem = prodList[prodIndex];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.amber,
          title: filteredItem == null ? Text('') : Text(filteredItem.title!)),
      body: filteredItem == null
          ? SizedBox()
          : ListView(
              children: [
                const SizedBox(height: 10),
                buildContainer(filteredItem.imageUrl!, filteredItem.id!),
                const SizedBox(height: 10),
                buildCard(filteredItem.title!, filteredItem.description!,
                    filteredItem.price!),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.pop(context, filteredItem.id);
        },
        child: const Icon(Icons.delete, color: Colors.black),
      ),
    );
  }

  Container buildContainer(String image, String id) {
    return Container(
      width: double.infinity,
      child: Center(
        child: Hero(
          tag: id,
          child: Image.network(image),
        ),
      ),
    );
  }

  Card buildCard(String title, String desc, double price) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(7),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.black),
            Text(desc,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify),
            const Divider(color: Colors.black),
            Text(
              "\$$price",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
