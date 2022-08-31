import 'package:aicycle_insurance_non_null_safety/aicycle_insurance.dart';
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
      home: const MyHomePage(title: 'Demo'),
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
        sessionId: '20220908142169',
        maDonVi: '016',
        phoneNumber: '0972795635',
        kieuCongViec: 'G',
        loaiCongViec: 'G',
        deviceId: '5EC1BDF2B4D1FD7B',
        maDonViNguoiDangNhap: '090',
        maGiamDinhVien: 'LDH',
        bienSoXe: '29A1223',
        hangXe: 'ACURA',
        hieuXe: 'CL',
        onGetResultCallBack: (data) {
          print(data.toString());
        },
        onError: (message) {
          // handle error here.
          print(message);
        },
        // Liên hệ để có token key
        uTokenKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiaWF0IjoxNjYxOTU1MDk3LCJleHAiOjE2NjIwNDE0OTd9.Gfk8WFS4Nl_Pmjg-dPu8XJC7_LkAK4BVD4AgGp23JHw',
      ),
    );
  }
}
