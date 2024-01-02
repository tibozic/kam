import 'package:flutter/material.dart';
import "post.dart";
import "postList.dart";
import "textInputWidget.dart";

/*class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nikov app"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: TextInputWidget(),
      /*body: Column(
        children: <Widget>[TestWidget(), TestWidget(), TestWidget()],
      ),*/
    );
  }
}*/

class MyHomePage extends StatefulWidget {
  final String name;

  const MyHomePage(this.name, {super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Post> posts = [];

  void newPost(String text) {
    setState(() {
      posts.add(new Post(text, widget.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Nikov app"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(
          children: [
            Expanded(
              child: PostList(this.posts),
            ),
            TextInputWidget(callback: newPost),
          ],
        ));
  }
}
