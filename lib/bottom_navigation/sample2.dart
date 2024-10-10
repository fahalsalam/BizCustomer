import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sample2 extends StatelessWidget {
  const Sample2({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: 50,
              itemBuilder: ((context, index) => SingleChildScrollView(
                      child: ListTile(
                    leading: Text("0"),
                  )))),
        );
      },
      // child:
    );
  }
}
