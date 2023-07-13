import 'dart:ui';

import 'package:toy_exchange_app/screens/auth/login_screen.dart';
import 'package:toy_exchange_app/screens/category/category_widget.dart';
import 'package:toy_exchange_app/components/main_appbar_with_search.dart';
import 'package:toy_exchange_app/components/product_listing_widget.dart';
import 'package:toy_exchange_app/constants/colors.dart';
import 'package:toy_exchange_app/constants/widgets.dart';
import 'package:toy_exchange_app/provider/category_provider.dart';
import 'package:toy_exchange_app/screens/location_screen.dart';
import 'package:toy_exchange_app/services/auth.dart';
import 'package:toy_exchange_app/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../provider/product_provider.dart';
import '../product/product_details_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String screenId = 'admin_home_screen';
  const AdminHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late TextEditingController searchController;
  late FocusNode searchNode;

  @override
  void initState() {
    searchController = TextEditingController();
    searchNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: MainAppBarWithSearch(
            controller: searchController, focusNode: searchNode),
      ),
      body: homeBodyWidget(),
    );
  }

  Widget homeBodyWidget() {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: (){
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.screenId);
            }, icon: Icon(Icons.logout)),
            Container(
              child: CategoryWidget(),
            ),
            ProductListing(),
            Divider(thickness: 2.0,height: 2.0,),
            Text("Reports"),
            Divider(thickness: 2.0,height: 2.0,),
            Reports(),
          ],
        ),
      ),
    );
  }
}

class locationTextWidget extends StatelessWidget {
  final String? location;
  const locationTextWidget({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.pin_drop,
          size: 18,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          location ?? '',
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
class Reports extends StatelessWidget {
   Reports({Key? key}) : super(key: key);

  Auth authService = Auth();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: authService.reports.where('isRead',isEqualTo: false).get(),
        builder: (ctx,AsyncSnapshot<QuerySnapshot> snapshot){
      if(snapshot.hasError){
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
          child: Text('No Report Found.'),
        ),
      )
          : Container(
        height: 500.0,
        child: ListView.builder(
            itemCount: snapshot.data!.size,
            itemBuilder: (ctx,index){
              var data = snapshot.data!.docs[index];
              var productProvider = Provider.of<ProductProvider>(context);
              return FutureBuilder<QuerySnapshot>(
                  future: authService.products.where('uid',isEqualTo: data['reportTo']).get(),
                  builder: (ctx,AsyncSnapshot<QuerySnapshot> snapshot){
                return ListTile(
                  onTap: () async {
                    // authService.updateIsRead(data['uid'], context);
                   final sellerDetails = await authService.users.doc(data['reportedUser']).get();
                    productProvider.setSellerDetails(sellerDetails);
                    productProvider.setProductDetails(snapshot.data!.docs.first);
                    Navigator.pushNamed(context, ProductDetail.screenId);
                  },
                  title: Text(data['report'],),
                  subtitle: Text(data['date']),
                  trailing: Icon(Icons.forward),
                );
              });


        }),
      );
    });
  }

  getDetails(String uid) async {
    return await authService.products.doc(uid).get();
  }

}
