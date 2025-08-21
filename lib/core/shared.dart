import 'package:flutter/material.dart';
PreferredSizeWidget buildAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.apps, color: Colors.white),
    ),
    title: Text(
      'Bezoni',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );
}
