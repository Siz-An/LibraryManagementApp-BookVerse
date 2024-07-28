import 'package:book_Verse/common/widgets/appbar/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class firstBooks extends StatelessWidget {
  const firstBooks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
      ),
    );
  }
}
