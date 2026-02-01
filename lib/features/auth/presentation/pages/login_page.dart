import 'package:flutter/material.dart';
import '../../../../core/utils/app_assets.dart';
import '../widgets/curved_background.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: const Stack(
          children: [
            CurvedBackground(),
            LoginForm(),

            Positioned(
              top: 20,
              left: 20,
              child: Image(
                image: AssetImage(AppAssets.logo),
                height: 45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
