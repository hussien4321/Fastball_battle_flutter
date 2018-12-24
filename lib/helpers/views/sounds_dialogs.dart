import 'package:flutter/material.dart';

class SoundsDialog extends StatelessWidget {
  

  bool isMusicOn, isTonesOn;
  int currentBGM;
  ValueChanged<bool> updateMusicSwitch, updateTonesSwitch;
  ValueChanged<int> updateBGM;
  VoidCallback onSave;

  SoundsDialog({this.isMusicOn, this.isTonesOn, this.currentBGM, this.updateMusicSwitch, this.updateTonesSwitch, this.updateBGM, this.onSave});


  @override
  Widget build(BuildContext context) {

    return CustomAlertDialog(
      title: Text('Sounds'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Music:', ),
                    Switch(
                      activeColor: Colors.orange[800],
                      value: isMusicOn,
                      onChanged: updateMusicSwitch,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Tones:', ),
                    Switch(
                      activeColor: Colors.orange[800],
                      value: isTonesOn,
                      onChanged: updateTonesSwitch,
                    )
                  ],
                ),
              ),
            ],
          ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('BGM Style:', textAlign: TextAlign.left, ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                //TODO: Change this list to be based on the entire list of _bgm from objects loader 
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0), 
                      bottomLeft: Radius.circular(5.0), 
                      topRight: Radius.circular(0.0), 
                      bottomRight: Radius.circular(0.0), 
                    ),
                  ),
                  color: Colors.orange,
                  child: Text('Fun',
                    style: Theme.of(context).textTheme.body1,
                  ),
                  onPressed: isMusicOn && currentBGM != 1 ? () {
                    updateBGM(1);
                  } : null,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0.0), 
                      bottomLeft: Radius.circular(0.0), 
                      topRight: Radius.circular(0.0), 
                      bottomRight: Radius.circular(0.0), 
                    ),
                  ),
                  color: Colors.orange,
                  child: Text('Epic',
                    style: Theme.of(context).textTheme.body1,
                  ),
                  onPressed: isMusicOn && currentBGM != 2 ? () {
                    updateBGM(2);
                  } : null,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0.0), 
                      bottomLeft: Radius.circular(0.0), 
                      topRight: Radius.circular(5.0), 
                      bottomRight: Radius.circular(5.0), 
                    ),
                  ),
                  color: Colors.orange,
                  child: Text('Peaceful',
                    style: Theme.of(context).textTheme.body1,
                  ),
                  onPressed: isMusicOn && currentBGM != 3 ? () {
                    updateBGM(3);
                  } : null,
                )
              ],
            )
          ),
        ],
      ),
      actions: <Widget>[
        RaisedButton(
          child: Text('Close', 
            style: Theme.of(context).textTheme.body1,
          ),
          onPressed: onSave,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class CustomAlertDialog extends StatelessWidget {

  Widget title, content; 
  List<Widget> actions;
  CustomAlertDialog({this.title, this.content, this.actions});

    Widget build(BuildContext context) {
      assert(debugCheckHasMaterialLocalizations(context));
      final List<Widget> children = <Widget>[];

      if (title != null) {
        children.add(Padding(
          padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.body1.merge(TextStyle(
              fontSize: 25.0,
            )),
            textAlign: TextAlign.center,
            child: Semantics(child: title, namesRoute: true),
          ),
        ));
      }

      if (content != null) {
        children.add(Flexible(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.body1,
              child: content,
            ),
          ),
        ));
      }

      if (actions != null) {
        children.add(ButtonTheme.bar(
          child: ButtonBar(
            children: actions,
          ),
        ));
      }

      Widget dialogChild = IntrinsicWidth(
        child: Container(
          color: Colors.orange[100],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      );

      return Dialog(child: dialogChild);
    }
}