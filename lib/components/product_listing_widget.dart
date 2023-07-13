import 'package:toy_exchange_app/constants/colors.dart';
import 'package:toy_exchange_app/provider/category_provider.dart';
import 'package:toy_exchange_app/provider/product_provider.dart';
import 'package:toy_exchange_app/screens/product/product_card.dart';
import 'package:toy_exchange_app/screens/product/product_details_screen.dart';
import 'package:toy_exchange_app/services/auth.dart';
import 'package:toy_exchange_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductListing extends StatefulWidget {
  final bool? isProductByCategory;

  const ProductListing({Key? key, this.isProductByCategory}) : super(key: key);

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  Auth authService = Auth();

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    var categoryProvider = Provider.of<CategoryProvider>(context);
    final numberFormat = NumberFormat('##,##,##0');
    return FutureBuilder<QuerySnapshot>(
        future: (widget.isProductByCategory == true)
            ? categoryProvider.selectedCategory == 'Toys'
                ? authService.products
                    .orderBy('posted_at')
                    .where('category',
                        isEqualTo: categoryProvider.selectedCategory)
                    .get()
                : authService.products
                    .orderBy('posted_at')
                    .where('category',
                        isEqualTo: categoryProvider.selectedCategory)
                    .where('subcategory',
                        isEqualTo: categoryProvider.selectedSubCategory)
                    .get()
            : authService.products.orderBy('posted_at').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products..'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }
          return (snapshot.data!.docs.isEmpty)
              ? SizedBox(
                  height: MediaQuery.of(context).size.height - 50,
                  child: const Center(
                    child: Text('No Products Found.'),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (widget.isProductByCategory != null)
                          ? const SizedBox()
                          : Container(
                              child: Column(
                                children: [
                                  Text(
                                    'Recommendation',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: blackColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                      GridView.builder(
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 2 / 2.8,
                            mainAxisExtent: 250,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: snapshot.data!.size,
                          itemBuilder: (BuildContext context, int index) {
                            var data = snapshot.data!.docs[index];
                            authService.updateUid(data.id,context);
                            var price = int.parse(data['price']);
                            String formattedPrice = numberFormat.format(price);
                            return ProductCard(
                              data: data,
                              formattedPrice: formattedPrice,
                              numberFormat: numberFormat,
                            );
                          }),
                    ],
                  ),
                );
        });
  }
}
