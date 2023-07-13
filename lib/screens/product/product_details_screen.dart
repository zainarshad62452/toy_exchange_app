import 'dart:async';

import 'package:toy_exchange_app/constants/colors.dart';
import 'package:toy_exchange_app/provider/product_provider.dart';
import 'package:toy_exchange_app/screens/chat/chat_screen.dart';
import 'package:toy_exchange_app/screens/chat/user_chat_screen.dart';
import 'package:toy_exchange_app/services/auth.dart';
import 'package:toy_exchange_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/validators.dart';
import '../../constants/widgets.dart';

class ProductDetail extends StatefulWidget {
  static const screenId = 'product_details_screen';
  const ProductDetail({Key? key}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late GoogleMapController _mapController;
  Auth authService = Auth();
  UserService firebaseUser = UserService();
  bool _loading = true;
  int _index = 0;
  bool isLiked = false;
  List fav = [];
  TextEditingController _reportController = TextEditingController();

  FocusNode _reportNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var productProvider = Provider.of<ProductProvider>(context);
    getFavourites(productProvider: productProvider);
    super.didChangeDependencies();
  }

  getFavourites({required ProductProvider productProvider}) {
    authService.products
        .doc(productProvider.productData!.id)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          fav = value['favourites'];
        });
      }
      if (fav.contains(firebaseUser.user!.uid)) {
        if (mounted) {
          setState(() {
            isLiked = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLiked = false;
          });
        }
      }
    });
  }

  _mapLauncher(location) async {
    final availableMaps = await launcher.MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
      coords: launcher.Coords(location.latitude, location.longitude),
      title: "Seller Location is here..",
    );
  }

  Future<void> _callLauncher(number) async {
    if (!await launchUrl(number)) {
      throw 'Could not launch $number';
    }
  }

  _createChatRoom(ProductProvider productProvider) {
    Map product = {
      'product_id': productProvider.productData!.id,
      'product_img': productProvider.productData!['images'][0],
      'price': productProvider.productData!['price'],
      'title': productProvider.productData!['title'],
      'seller': productProvider.productData!['seller_uid'],
    };
    List<String> users = [
      productProvider.sellerDetails!['uid'],
      firebaseUser.user!.uid,
    ];
    String chatroomId =
        '${productProvider.sellerDetails!['uid']}.${firebaseUser.user!.uid}${productProvider.productData!.id}';
    Map<String, dynamic> chatData = {
      'users': users,
      'chatroomId': chatroomId,
      'read': false,
      'product': product,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch,
    };
    firebaseUser.createChatRoom(data: chatData);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => UserChatScreen(
                  chatroomId: chatroomId,
                )));
  }

  _body({
    required DocumentSnapshot<Object?> data,
    required String formattedDate,
    required ProductProvider productProvider,
    required String formattedPrice,
    required GeoPoint location,
    required NumberFormat numberFormat,
  }) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 450,
                        color: Colors.transparent,
                        child: _loading
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: secondaryColor,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Loading..',
                                    )
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  Center(
                                    child: Image.network(
                                      data['images'][_index],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      height: 60,
                                      color: whiteColor,
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListView.builder(
                                            physics: ScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: data['images'].length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _index = index;
                                                  });
                                                },
                                                child: Container(
                                                  width: 100,
                                                  color: whiteColor,
                                                  child: Image.network(
                                                      data['images'][index]),
                                                ),
                                              );
                                            }),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ),
                      _loading
                          ? Container()
                          : Container(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data['title'].toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Rs ${formattedPrice}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(data['description']),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 10,
                                                  ),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: disabledColor
                                                      .withOpacity(0.3),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Posted At: ${formattedDate}',
                                                        style: TextStyle(
                                                          color: blackColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: blackColor,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: primaryColor,
                                          radius: 40,
                                          child: CircleAvatar(
                                            backgroundColor: secondaryColor,
                                            radius: 37,
                                            child: Icon(
                                              CupertinoIcons.person,
                                              color: whiteColor,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            title: Text(
                                              productProvider
                                                  .sellerDetails!['name']
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            subtitle: Text(
                                              'View Profile',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: linkColor,
                                              ),
                                            ),
                                            trailing: IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: linkColor,
                                                  size: 12,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Divider(
                                      color: blackColor,
                                    ),
                                    Text(
                                      'Ad Post at:',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 200,
                                      color: disabledColor.withOpacity(0.3),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                zoom: 15,
                                                target: LatLng(
                                                  location.latitude,
                                                  location.longitude,
                                                ),
                                              ),
                                              mapType: MapType.normal,
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                setState(() {
                                                  _mapController = controller;
                                                });
                                              },
                                            ),
                                          ),
                                          Center(
                                              child: Icon(
                                            Icons.location_pin,
                                            color: Colors.red,
                                            size: 35,
                                          )),
                                          Center(
                                            child: CircleAvatar(
                                              radius: 60,
                                              backgroundColor:
                                                  blackColor.withOpacity(0.1),
                                            ),
                                          ),
                                          Positioned(
                                            right: 4,
                                            top: 4,
                                            child: Material(
                                              elevation: 4,
                                              shape: Border.all(
                                                  color: disabledColor
                                                      .withOpacity(0.2)),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.alt_route_outlined,
                                                ),
                                                onPressed: () async {
                                                  await _mapLauncher(location);
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Ad Id: ${data['posted_at']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(context: context, builder: (ctx){
                                                  return AlertDialog(
                                                    title: Text("Report User"),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Form(
                                                          key: _formKey,
                                                          child: TextFormField(
                                                            focusNode: _reportNode,
                                                            validator: (value) {
                                                              return checkNullEmptyValidation(
                                                                  value, 'report');
                                                            },
                                                            controller: _reportController,
                                                            keyboardType: TextInputType.name,
                                                            decoration: InputDecoration(
                                                                labelText: 'Report',
                                                                labelStyle: TextStyle(
                                                                  color: greyColor,
                                                                  fontSize: 14,
                                                                ),
                                                                hintText: 'Please enter the issue',
                                                                hintStyle: TextStyle(
                                                                  color: greyColor,
                                                                  fontSize: 14,
                                                                ),
                                                                contentPadding: const EdgeInsets.all(15),
                                                                border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8))),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10.0,),
                                                        roundedButton(
                                                            context: context,
                                                            bgColor: secondaryColor,
                                                            text: 'Submit',
                                                            textColor: whiteColor,
                                                            onPressed: () async {
                                                              if (_formKey.currentState!.validate()) {
                                                                authService.submitReport(context,_reportController.text,data['uid'],firebaseUser.user!.uid,data['seller_uid']);
                                                              }
                                                            }),
                                                      ],
                                                    ),
                                                  );
                                                });
                                              },
                                              child: Text(
                                                'REPORT AD',
                                                style: TextStyle(color: linkColor),
                                              ),
                                            )
                                          ],
                                        ),
                                        Visibility(
                                          visible: authService.currentUser!.email == kAdminEmail,
                                          child: roundedButton(bgColor: Colors.red, onPressed: (){
                                            authService.blockUser(productProvider
                                                .sellerDetails!['uid'], context);
                                          }, text: "Block User"),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 80,
                                    ),

                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  _bottomSheet({required ProductProvider productProvider}) {
    return BottomAppBar(
      child: Padding(
        padding: (productProvider.productData!['seller_uid'] ==
                firebaseUser.user!.uid)
            ? EdgeInsets.zero
            : EdgeInsets.all(16),
        child: (productProvider.productData!['seller_uid'] ==
                firebaseUser.user!.uid)
            ? null
            : Row(children: [
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(secondaryColor)),
                      onPressed: () {
                        _createChatRoom(productProvider);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              size: 16,
                              color: whiteColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Request Toy',
                            )
                          ],
                        ),
                      )),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(secondaryColor)),
                      onPressed: () async {
                        var phoneNo = Uri.parse(
                            'tel:${productProvider.sellerDetails!['mobile']}');
                        await _callLauncher(phoneNo);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.call,
                              size: 16,
                              color: whiteColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Call',
                            )
                          ],
                        ),
                      )),
                )
              ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    final numberFormat = NumberFormat('##,##,##0');
    var data = productProvider.productData;
    var _price = int.parse(data!['price']);
    var formattedPrice = numberFormat.format(_price);
    var date = DateTime.fromMicrosecondsSinceEpoch(data['posted_at']);
    var formattedDate = DateFormat.yMMMd().format(date);
    GeoPoint _location = productProvider.sellerDetails!['location'];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          iconTheme: IconThemeData(color: blackColor),
          title: Text(
            'Product Details',
            style: TextStyle(color: blackColor),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: blackColor,
              ),
              onPressed: () {},
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                  firebaseUser.updateFavourite(
                    context: context,
                    isLiked: isLiked,
                    productId: data.id,
                  );
                },
                color: isLiked ? secondaryColor : disabledColor,
                icon: Icon(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                ))
          ],
        ),
        body: _body(
            data: data,
            formattedDate: formattedDate,
            productProvider: productProvider,
            formattedPrice: formattedPrice,
            location: _location,
            numberFormat: numberFormat),
        bottomSheet: _loading
            ? SizedBox()
            : _bottomSheet(productProvider: productProvider));
  }
}
