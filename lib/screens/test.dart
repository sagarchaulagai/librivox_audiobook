import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Ink(
            height: 300,
            width: 300,
            child: InkWell(
              splashFactory: InkRipple.splashFactory,
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              onLongPress: () {},
              splashColor: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}
