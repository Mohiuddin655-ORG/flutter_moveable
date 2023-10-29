# flutter_moveable
This is a object moveable widget for use one to one video or audio calling, message heads like messenger etc.

## Message Head Style
![heads](https://github.com/Mohiuddin655-ORG/flutter_moveable/assets/71176567/ed59669f-416d-4b4b-9baf-57ea0e919120)

## One to One Calling Style
![one2onecalling](https://github.com/Mohiuddin655-ORG/flutter_moveable/assets/71176567/e432b5ed-16ac-44c9-9e88-93e127100bad)

## Features
* Anywhere placement system
* Dock Horizontal placement system
* Dock Vertical placement system
* Any center side placement system
* Any corner placement system
* Any nearest placement system
* Center in Bottom and Top side placement system
* Center in Bottom and Top any corner placement system
* Center in Top and Bottom any side placement system
* Center in Top and Bottom any corner placement system
* Center in Left and Right any side placement system
* Center in Left and Right any corner placement system
* Center in Right and Left any side placement system
* Center in Right and Left any corner placement system

## Usage

```dart

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
            maxWidth: 60,
            ratio: 1,
            margin: const EdgeInsets.only(top: 40),
            builder: (dragging, child) {
              return Center(
                child: AnimatedContainer(
                  width: dragging ? 50 : 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
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


```


