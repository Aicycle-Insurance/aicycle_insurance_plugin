import 'package:aicycle_insurance/aicycle_insurance.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'DEmo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ClaimFolderView(
        sessionId: '288', // fake session id
        carBrand: CarBrandType.mazdaCX5,
        onError: (message) {
          // handle error here.
          print(message);
        },
        uTokenKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsImlhdCI6MTY2MDA1Mjk1NSwiZXhwIjoxNjYwMTM5MzU1fQ.lqvSOMlVYM9C_lS-cGvev1ICSUFcc_uVEgrV5X8zoLs', // Liên hệ để có token key
      ),
    );
  }
}
