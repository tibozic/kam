import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  //const TextInputWidget({super.key});
  final Function(String) callback;

  const TextInputWidget({required this.callback, Key? key}) : super(key: key);

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  final controller = TextEditingController();
  //String text = "";

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  /*void changeText(text) {
    if (text == "Hello world!") {
      controller.clear();
      text = "";
    }
    setState(() {
      this.text = text;
    });
  }*/

  void click() {
    FocusScope.of(context).unfocus();
    widget.callback(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    //return const Placeholder();
    //return Column(children: [
    return TextField(
      controller: this.controller,
      decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.message, color: Theme.of(context).colorScheme.primary),
          labelText: "Type a message:",
          suffixIcon: IconButton(
            icon: Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
            splashColor: Theme.of(context).colorScheme.primary,
            tooltip: "Post message",
            //onPressed: () => {},
            onPressed: this.click,
          )),
      //onChanged: (text) => this.changeText(text),
    );
    //Text(this.text)
  }
}
