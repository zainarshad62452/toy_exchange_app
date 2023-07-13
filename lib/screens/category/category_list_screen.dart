import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:toy_exchange_app/constants/validators.dart';
import 'package:toy_exchange_app/provider/category_provider.dart';
import 'package:toy_exchange_app/screens/category/product_by_category_screen.dart';
import 'package:toy_exchange_app/screens/category/subcategory_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/image_picker_widget.dart';
import '../../constants/colors.dart';
import '../../constants/widgets.dart';
import '../../services/auth.dart';

class CategoryListScreen extends StatefulWidget {
  final bool? isForForm;
  static const String screenId = 'category_list_screen';
  const CategoryListScreen({Key? key, this.isForForm}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {

  TextEditingController _categoryNameController = TextEditingController();
  TextEditingController _subCategoryController1 = TextEditingController();
  TextEditingController _subCategoryController2 = TextEditingController();
  TextEditingController _subCategoryController3 = TextEditingController();
  TextEditingController _subCategoryController4 = TextEditingController();

  FocusNode _categoryNode = FocusNode();
  FocusNode _subCategoryNode1 = FocusNode();
  FocusNode _subCategoryNode2 = FocusNode();
  FocusNode _subCategoryNode3 = FocusNode();
  FocusNode _subCategoryNode4 = FocusNode();
  Auth authService = Auth();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
        title: Text(
          widget.isForForm == true ? 'Select Category' : 'Categories',
          style: TextStyle(color: blackColor),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: (){
          showDialog(context: context, builder: (ctx){
            return AlertDialog(
              title: Text("Add Category"),
              content: addCategoryForm(categoryProvider, context),
            );
          });

        },child: Icon(Icons.add,color: Colors.white,),),
      body: _body(categoryProvider),
    );
  }

  Column addCategoryForm(CategoryProvider categoryProvider, BuildContext context) {
    return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        focusNode: _categoryNode,
                        validator: (value) {
                          return checkNullEmptyValidation(
                              value, 'category name');
                        },
                        controller: _categoryNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            labelText: 'Category Name',
                            labelStyle: TextStyle(
                              color: greyColor,
                              fontSize: 14,
                            ),
                            hintText: 'Enter Category Name',
                            hintStyle: TextStyle(
                              color: greyColor,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  focusNode: _subCategoryNode1,
                  validator: (value) {
                    return checkNullEmptyValidation(
                        value, 'sub category name');
                  },
                  controller: _subCategoryController1,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: 'Sub Category',
                      labelStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      hintText: 'Enter Sub Category',
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  focusNode: _subCategoryNode2,
                  validator: (value) {
                    return checkNullEmptyValidation(
                        value, 'sub category name');
                  },
                  controller: _subCategoryController2,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: 'Sub Category',
                      labelStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      hintText: 'Enter Sub Category',
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  focusNode: _subCategoryNode3,
                  validator: (value) {
                    return checkNullEmptyValidation(
                        value, 'sub category name');
                  },
                  controller: _subCategoryController3,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: 'Sub Category',
                      labelStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      hintText: 'Enter Sub Category',
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  focusNode: _subCategoryNode4,
                  validator: (value) {
                    return checkNullEmptyValidation(
                        value, 'sub category name');
                  },
                  controller: _subCategoryController4,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: 'Sub Category',
                      labelStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      hintText: 'Enter Sub Category',
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    if (kDebugMode) {
                      print(categoryProvider.imageUploadedUrls.length);
                    }
                    return openBottomSheet(
                        context: context, child: const ImagePickerWidget());
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Colors.grey[300],
                    ),
                    child: Text(
                      categoryProvider.imageUploadedUrls.isNotEmpty
                          ? 'Upload More Images'
                          : 'Upload Image',
                      style: TextStyle(
                          color: blackColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                roundedButton(
                    context: context,
                    bgColor: secondaryColor,
                    text: 'Submit',
                    textColor: whiteColor,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if(categoryProvider.imageUploadedUrls.isEmpty){
                          customSnackBar(context: context, content: "Please select an image");
                        }
                        List<String> subCategory = [];
                        subCategory.add(_subCategoryController1.text);
                        subCategory.add(_subCategoryController2.text);
                        subCategory.add(_subCategoryController3.text);
                        subCategory.add(_subCategoryController4.text);
                        final newCategory = authService.categories.doc();
                        Map<String,dynamic> map = {
                          "category_name": _categoryNameController.text,
                          "img":  categoryProvider.imageUploadedUrls[0],
                          "subcategory": subCategory,
                          "uid":newCategory.id,
                        };

                        newCategory.set(map).then((value) => Navigator.pop(context));
                      }
                    }),
              ],
            );
  }

  _body(categoryProvider) {
    Auth authService = Auth();

    return FutureBuilder<QuerySnapshot>(
        future: authService.categories.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: ((context, index) {
                var doc = snapshot.data?.docs[index];
                return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () {
                        categoryProvider.setCategory(doc!['category_name']);
                        categoryProvider.setCategorySnapshot(doc);
                        if (widget.isForForm == true) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => SubCategoryScreen(
                                        doc: doc, isForForm: true)));
                        } else {
                          if (doc['subcategory'] == null) {
                            Navigator.of(context)
                                .pushNamed(ProductByCategory.screenId);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => SubCategoryScreen(
                                          doc: doc,
                                        )));
                          }
                        }
                      },
                      leading: Image.network(doc!['img']),
                      title: Text(
                        doc['category_name'],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      trailing: doc['subcategory'] != null
                          ? const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            )
                          : null,
                      subtitle: loginUser=='admin'?IconButton(onPressed: (){
                        authService.deleteCategory(doc['uid'], context);
                      }, icon: Icon(Icons.delete_forever,color: Colors.red,)):SizedBox(),
                    ));
              }));
        });
  }
}
