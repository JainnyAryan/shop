import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/screens/product_details_screen.dart';

import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
              icon: Consumer<Product>(
                builder: (ctx, product, child) => Icon(
                  // child argument is useful to pass a child widget in the builder which is constant and doesnt depend on data
                  //child can be passed by child property of Consumer
                  product.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_border_outlined,
                ),
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavouriteStatus(authData.token, authData.userId);
              }),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: (() {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Added to cart!"),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ),
              );
            }),
          ),
        ),
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                image: NetworkImage(product.imageUrl),
                placeholder: const AssetImage("assets/images/product-placeholder.png"),
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}
