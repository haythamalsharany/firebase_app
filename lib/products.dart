// ignore_for_file: argument_type_not_assignable_to_error_handler

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
  });
}

class Products with ChangeNotifier {
  List<Product> productsList = [];

  String? authToken;

  Products();

  Products.update({required this.authToken, required this.productsList});

  Future<void> add(
      {String? id,
      String? title,
      String? description,
      double? price,
      String? imageUrl}) async {
    try {
      String url =
          'https://hassan1-e78fc-default-rtdb.firebaseio.com/product.json?auth=$authToken';
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            'id': id,
            'title': title,
            'description': description,
            'price': price,
            'imageUrl': imageUrl
          }));
      productsList.add(Product(
        id: json.decode(res.body)['name'],
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      ));
      // ignore: avoid_print
      print(imageUrl);

      notifyListeners();
      // ignore: empty_catches
    } catch (error) {}
  }

  update(String? pAuthToken, List<Product> pListPro) {
    // productsList=p_prodList;
    authToken = pAuthToken;
    productsList = pListPro;
  }

  Future<void> fetchData() async {
    try {
      String url =
          'https://hassan1-e78fc-default-rtdb.firebaseio.com/product.json?auth=$authToken';
      http.Response res = await http.get(Uri.parse(url));

      final Map<String, dynamic> extractedData =
          json.decode(res.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        final productIndex =
            productsList.indexWhere((element) => element.id == prodId);
        if (productIndex >= 0) {
          productsList[productIndex] = Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl']);
        } else {
          productsList.add(Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'])); //}
        }
      });
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  void delete(String id) async {
    String url =
        'https://hassan1-e78fc-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
    final prodIndex = productsList.indexWhere((element) => element.id == id);
    Product? prodItem = productsList[prodIndex];
    try {
      productsList.removeAt(prodIndex);
      notifyListeners();
      var res = await http.delete(Uri.parse(url));

      prodItem = null;
      // ignore: avoid_print
      print("Item Deleted");
    } catch (e) {
      /* productsList.insert(prodIndex, prodItem!);
      notifyListeners();*/
      throw e;
    }
  }
}
