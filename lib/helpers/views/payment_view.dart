import 'package:flutter/material.dart';
import '../../models/enemy.dart';

class PaymentView extends StatelessWidget {
  //payment id

  Widget image;
  String paymentName;
  String paymentDescription;
  bool unlocked;
  VoidCallback onClick;

  PaymentView(
      {this.image,
      this.paymentName,
      this.paymentDescription,
      this.unlocked,
      this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(height: 125.0, padding: EdgeInsets.all(10.0), child: image),
          Padding(
            padding: EdgeInsets.only(bottom: 5.0),
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            child: Text(
              paymentName,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .apply(fontSizeFactor: 1.5),
            ),
          ),
          Expanded(
            child: Container(
              child: Text(
                paymentDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .apply(color: Colors.grey[800]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 5.0),
          ),
          RaisedButton(
            child: Text(
              unlocked ? 'Purchased' : 'Purchase',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            color: Colors.greenAccent,
            onPressed: unlocked ? null : onClick,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 5.0),
          ),
        ],
      ),
    );
  }
}
