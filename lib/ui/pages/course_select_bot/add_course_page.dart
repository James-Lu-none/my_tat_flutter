import 'package:flutter/material.dart';

class CustomPopup extends StatefulWidget {
  final Function(String) onSubmit;
  const CustomPopup({required this.onSubmit, super.key});

  @override
  State<StatefulWidget> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Custom Popup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _textFieldController,
            decoration: InputDecoration(labelText: 'Enter Text'),
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Perform an action when the button is pressed
                  String enteredText = _textFieldController.text;
                  if (enteredText.length != 6) return;
                  widget.onSubmit(enteredText);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
