import 'package:toy_exchange_app/forms/common_form.dart';
import 'package:toy_exchange_app/provider/category_provider.dart';
import 'package:toy_exchange_app/screens/category/product_by_category_screen.dart';
import 'package:toy_exchange_app/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';

class SubCategoryScreen extends StatefulWidget {
  final DocumentSnapshot? doc;
  final bool? isForForm;
  static const String screenId = 'subcategory_screen';
  const SubCategoryScreen({Key? key, this.doc, this.isForForm})
      : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
        backgroundColor: whiteColor,
        title: Text(
          widget.doc!['category_name'] ?? '',
          style: TextStyle(color: blackColor),
        ),
      ),
      body: _body(widget.doc, categoryProvider, widget.isForForm),
    );
  }

  _body(args, CategoryProvider categoryProvider, bool? isForForm) {
    Auth authService = Auth();
    return FutureBuilder<DocumentSnapshot>(
        future: authService.categories.doc(args.id).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }
          var data = snapshot.data!['subcategory'];
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: ((context, index) {
                return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () {
                        categoryProvider.setSubCategory(data[index]);

                        if (isForForm == true) {
                          Navigator.pushNamed(context, CommonForm.screenId);
                        } else {
                          Navigator.pushNamed(
                            context,
                            ProductByCategory.screenId,
                          );
                        }
                      },
                      title: Text(
                        data[index],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ));
              }));
        });
  }
}
