import 'package:flutter/material.dart';

import 'custoom_widget.dart';


class PercnTageWidget extends StatelessWidget {
  final double percentage;
  PercnTageWidget(this.percentage);
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CircularPercentIndicator(
          radius: 210.0,
          lineWidth: 18.0,
          percent: percentage,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("34%",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Text("PAID")
            ],
          ),
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.transparent,
          maskFilter: MaskFilter.blur(BlurStyle.solid, 3),
          linearGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
          ),
        ),
        Container(
          width: 225,
          height: 225,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(.2),width: 35),
            borderRadius: BorderRadius.circular(200),
          ),
        ),
      ],
    );
  }
}
