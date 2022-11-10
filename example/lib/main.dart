import 'package:aicycle_insurance_non_null_safety/aicycle_insurance.dart';
import 'package:flutter/cupertino.dart';
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
      title: 'SDK Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstPage(title: 'SDK Demo'),
      // home: MyHomePage(
      //   title: 'SDK Demo',
      //   sessionId: '9',
      // ),
    );
  }
}

class FirstPage extends StatefulWidget {
  FirstPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String sessionId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nhập mã hồ sơ'),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (str) {
                  setState(() {
                    sessionId = str;
                  });
                },
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                color: Colors.blue,
                child: Text('Next'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(
                        title: widget.title,
                        sessionId: sessionId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title, this.sessionId}) : super(key: key);

  final String title;
  final String sessionId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    print(widget.sessionId);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: true,
      ),
      body: ClaimFolderView(
          sessionId: widget.sessionId,
          maDonVi: '016',
          phoneNumber: '0972795635',
          kieuCongViec: 'G',
          loaiCongViec: 'G',
          deviceId: '5EC1BDF2B4D1FD7B',
          maDonViNguoiDangNhap: '090',
          maGiamDinhVien: 'LDH',
          bienSoXe: '29A1223',
          hangXe: 'TOYOTA',
          hieuXe: 'VIOS E',
          onGetResultCallBack: (data) {
            print(data.toString());
          },
          onError: (message) {
            // handle error here.
            print(message);
          },
          // Liên hệ để có token key
          uTokenKey:
              '415b98:36d05f98db9141aabbb137f279c29df67007623902844672a4f5f7c4352b554f'
          // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNyIsImlhdCI6MTY2MTMwNzQ3OCwiZXhwIjoxNzQ3NzA3NDc4fQ.Uk9RRkXmVxCh9xoiOrzVlF6z2Yku9u8f1w6jHanY-V8',
          ),
    );
  }
}
