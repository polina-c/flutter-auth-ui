import 'dart:math';

import 'package:flutter/material.dart';

/// Provides default layout for authentication screen
class DefaultScreenBuilder {
  static const double _boxWidth = 200;
  static const double _boxHeight = 400;

  static Widget builder(
    BuildContext context,
    String title,
    Widget content,
    VoidCallback close,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double vInsets = max(5, (screenHeight - _boxHeight) / 2);
    double hInsets = max(5, (screenWidth - _boxWidth) / 2);
    return Scaffold(
        body: Container(
      padding: EdgeInsets.symmetric(vertical: vInsets, horizontal: hInsets),
      width: screenWidth,
      height: screenHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: Theme.of(context).textTheme.title.fontSize,
                  ),
                  onPressed: close,
                ),
              ],
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.title,
            ),
            content,
          ],
        ),
      ),
    ));
  }
}
