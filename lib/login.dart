import 'package:flutter/material.dart';
import 'package:kam/myHomePage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nikov app"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late String name;
  TextEditingController controller = new TextEditingController();

  void click() {
    this.name = controller.text;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MyHomePage(this.name)));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: this.controller,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.primary),
              labelText: "Type your name:",
              border: OutlineInputBorder(
                  borderSide: BorderSide(width: 5, color: Colors.black)),
              suffixIcon: IconButton(
                icon: Icon(Icons.done),
                color: Theme.of(context).colorScheme.primary,
                splashColor: Theme.of(context).colorScheme.primary,
                tooltip: "Login",
                //onPressed: () => {},
                onPressed: this.click,
              )),
        ),
      ),
    );
  }
}
