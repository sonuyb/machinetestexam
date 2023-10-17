import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductPage extends StatefulWidget {
  final int productId;

  ProductPage({required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Map<String, dynamic> product = {};
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController thumbnailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final url = 'https://dummyjson.com/products/${widget.productId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is Map<String, dynamic>) {
        setState(() {
          product = jsonData;
          titleController.text = product['title'];
          priceController.text = product['price'].toString();
          thumbnailController.text = product['thumbnail'];
          descriptionController.text = product['description'];
        });
      } else {
        print('Invalid product data format');
      }
    } else {
      print('Failed to fetch product details. Status code: ${response.statusCode}');
    }
  }

  void _toggleEditing() {
    if (isEditing) {
      updateProductDetails();
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> updateProductDetails() async {
    final url = 'https://dummyjson.com/products/${widget.productId}';
    final updatedProductData = {
      'title': titleController.text,
      'price': double.parse(priceController.text),
      'thumbnail': thumbnailController.text,
      'description': descriptionController.text,
    };

    // Send a PUT request to update the product
    final response = await http.put(
      Uri.parse(url),
      body: json.encode(updatedProductData),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Product details updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green, // Customize the toast appearance
        textColor: Colors.white,
      );
      print('Product details updated successfully');
    } else {
      print('Failed to update product details. Status code: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (!isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Title:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(product['title']),
                  SizedBox(height: 12),
                  Text(
                    'Product Price:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('\$${product['price']}'),
                  SizedBox(height: 12),
                  Text(
                    'Product Thumbnail:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Image.network(product['thumbnail']),
                  SizedBox(height: 12),
                  Text(
                    'Product Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(product['description']),
                ],
              ),
            if (isEditing)
              Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Product Title'),
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Product Price'),
                  ),
                  TextFormField(
                    controller: thumbnailController,
                    decoration: InputDecoration(labelText: 'Product Thumbnail'),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Product Description'),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: _toggleEditing,
              child: Text(isEditing ? 'Save' : 'Edit Product Details'),
            ),
          ],
        ),
      ),
    );
  }
}
