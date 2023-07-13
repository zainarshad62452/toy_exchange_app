import 'package:toy_exchange_app/constants/colors.dart';
import 'package:toy_exchange_app/forms/common_form.dart';
import 'package:toy_exchange_app/forms/user_form_review.dart';
import 'package:toy_exchange_app/provider/category_provider.dart';
import 'package:toy_exchange_app/provider/product_provider.dart';
import 'package:toy_exchange_app/screens/admin/admin_home_screen.dart';
import 'package:toy_exchange_app/screens/auth/email_verify_screen.dart';
import 'package:toy_exchange_app/screens/auth/login_screen.dart';
import 'package:toy_exchange_app/screens/auth/register_screen.dart';
import 'package:toy_exchange_app/screens/category/product_by_category_screen.dart';
import 'package:toy_exchange_app/screens/category/subcategory_screen.dart';
import 'package:toy_exchange_app/screens/chat/user_chat_screen.dart';
import 'package:toy_exchange_app/screens/home_screen.dart';
import 'package:toy_exchange_app/screens/location_screen.dart';
import 'package:toy_exchange_app/screens/main_navigatiion_screen.dart';
import 'package:toy_exchange_app/screens/post/my_post_screen.dart';
import 'package:toy_exchange_app/screens/product/product_details_screen.dart';
import 'package:toy_exchange_app/screens/profile_screen.dart';
import 'package:toy_exchange_app/screens/splash_screen.dart';
import 'package:toy_exchange_app/screens/welcome_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/reset_password_screen.dart';
import 'screens/category/category_list_screen.dart';
import 'screens/chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        )
      ],
      child: const Main(),
    ),
  );
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: blackColor,
          backgroundColor: whiteColor,
          fontFamily: 'Oswald',
          scaffoldBackgroundColor: whiteColor,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.screenId,
        routes: {
          SplashScreen.screenId: (context) => const SplashScreen(),
          LoginScreen.screenId: (context) => const LoginScreen(),
          LocationScreen.screenId: (context) => const LocationScreen(),
          HomeScreen.screenId: (context) => const HomeScreen(),
          WelcomeScreen.screenId: (context) => const WelcomeScreen(),
          RegisterScreen.screenId: (context) => const RegisterScreen(),
          AdminHomeScreen.screenId: (context) => const AdminHomeScreen(),
          EmailVerifyScreen.screenId: (context) => const EmailVerifyScreen(),
          ResetPasswordScreen.screenId: (context) =>
              const ResetPasswordScreen(),
          CategoryListScreen.screenId: (context) => const CategoryListScreen(),
          SubCategoryScreen.screenId: (context) => const SubCategoryScreen(),
          MainNavigationScreen.screenId: (context) =>
              const MainNavigationScreen(),
          ChatScreen.screenId: (context) => const ChatScreen(),
          MyPostScreen.screenId: (context) => const MyPostScreen(),
          ProfileScreen.screenId: (context) => const ProfileScreen(),
          UserFormReview.screenId: (context) => const UserFormReview(),
          CommonForm.screenId: (context) => const CommonForm(),
          ProductDetail.screenId: (context) => const ProductDetail(),
          ProductByCategory.screenId: (context) => const ProductByCategory(),
          UserChatScreen.screenId: (context) => const UserChatScreen(),
        });
  }
}
