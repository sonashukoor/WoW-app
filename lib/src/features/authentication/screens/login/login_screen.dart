import 'package:flutter/material.dart';
import 'package:wow_app/src/constants/image_strings.dart';
import 'package:wow_app/src/constants/text_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.all(30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image(
                image: AssetImage(tWelcomeScreenImage),
                height: size.height * 0.2),
            Text(tLoginTitle,
                style: Theme.of(context).textTheme.headlineMedium),
            Text(tLoginSubtitle, style: Theme.of(context).textTheme.bodyMedium),
          ])),
    ));
  }
}
