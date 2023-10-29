import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moveable/flutter_moveable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
        ),
        body: Moveable(
          alignment: Alignment.topRight,
          type: MovingType.cornerSide,
          movedAnimationTime: 200,
          movingAnimationTime: 50,
          object: MoveableObject.rational(
            maxWidth: 120,
            ratio: 1 / 1.5,
            margin: const EdgeInsets.only(
              top: 40,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            builder: (dragging, child) {
              return Center(
                child: AnimatedContainer(
                  width: dragging ? 100 : 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  duration: const Duration(milliseconds: 200),
                  child: child,
                ),
              );
            },
            child: Image.asset(
              "assets/images/img_avatar.png",
              fit: BoxFit.cover,
            ),
          ),
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
