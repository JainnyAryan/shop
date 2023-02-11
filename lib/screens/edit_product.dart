import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';

import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // final _titleFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imgURLFocusNode = FocusNode();
  final _imgURLcontroller = TextEditingController();
  final _form = GlobalKey<FormState>();

  Product _editedProduct = Product(
    id: null.toString(),
    imageUrl: "",
    price: 0,
    title: "",
    description: "",
  );

  var _initvalues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imgURLFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imgURLFocusNode.hasFocus) {
      if ((!_imgURLcontroller.text.startsWith('http') &&
          !_imgURLcontroller.text.startsWith('https'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imgURLFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imgURLcontroller.dispose();
    _imgURLFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isvalid = _form.currentState!.validate();
    if (!isvalid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null.toString()) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("An error occured!"),
            content: const Text("Something went wrong."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text("Okay"),
              )
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        _initvalues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': "",
        };
        _imgURLcontroller.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initvalues['title'],
                      decoration: const InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      // focusNode: _titleFocusNode,
                      onFieldSubmitted: ((_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      }),
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: value as String,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please provide a value!";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initvalues['price'],
                      decoration: const InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: ((value) {
                        FocusScope.of(context).requestFocus(_descFocusNode);
                      }),
                      onSaved: (newValue) {
                        print(newValue);
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(newValue as String),
                            title: _editedProduct.title,
                            isFavourite: _editedProduct.isFavourite,
                            description: _editedProduct.description);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter some value!";
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid number!';
                        }
                        if (double.parse(value) <= 0) {
                          return "Price should be greater than 0.";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initvalues['description'],
                      decoration:
                          const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descFocusNode,
                      onSaved: (newValue) {
                        print(newValue);
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            description: newValue as String,
                            isFavourite: _editedProduct.isFavourite,
                            title: _editedProduct.title);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a description.";
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imgURLcontroller.text.isEmpty
                              ? const Text("Enter a URL !")
                              : Container(
                                  child: Image.network(
                                    _imgURLcontroller.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Image URL"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imgURLcontroller,
                            focusNode: _imgURLFocusNode,
                            // onEditingComplete: () {
                            //   setState(() {});
                            // },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (newValue) {
                              // print(newValue);
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  imageUrl: newValue as String,
                                  price: _editedProduct.price,
                                  title: _editedProduct.title,
                                  isFavourite: _editedProduct.isFavourite,
                                  description: _editedProduct.description);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter image URL.";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return 'Enter valid URL.';
                              }
                              if (!value.endsWith("jpg") &&
                                  !value.endsWith("png")) {
                                return 'Enter valid URL.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
