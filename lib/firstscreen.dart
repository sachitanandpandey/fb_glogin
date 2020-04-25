import 'package:fb_glogin/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:fb_glogin/NavDrawer.dart';
import 'package:fb_glogin/login_page.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

 final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  
   

  String assetPDFPath = "";
  String urlPDFPath = "";

  @override
  void initState() {
    super.initState();

    // getFileFromAsset("assets/mypdf.pdf").then((f) {
    //   setState(() {
    //     assetPDFPath = f.path;
    //     print(assetPDFPath);
    //   });
    // });

    getFileFromUrl("https://ukione.s3-eu-west-1.amazonaws.com/mai-kaun-hu.pdf")
        .then((f) {
      setState(() {
        urlPDFPath = f.path;
        print(urlPDFPath);
      });
    });
  }

  // Future<File> getFileFromAsset(String asset) async {
  //   try {
  //     var data = await rootBundle.load(asset);
  //     var bytes = data.buffer.asUint8List();
  //     var dir = await getApplicationDocumentsDirectory();
  //     File file = File("${dir.path}/mypdf.pdf");

  //     File assetFile = await file.writeAsBytes(bytes);
  //     return assetFile;
  //   } catch (e) {
  //     throw Exception("Error opening asset file");
  //   }
  // }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mai-kaun-hu.pdf");
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: NavDrawer(),
          appBar: AppBar(
            title: Text("Main Kaun Hu"),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/mainkaunhu.jpg"),
                fit: BoxFit.cover,
              ),
              //color: Colors.white,
            ),
            child: Center(
              child: Builder(
                builder: (context) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.amber,
                      child: Text("Start Reading"),
                      onPressed: () {
                        if (urlPDFPath != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PdfViewPage(path: urlPDFPath)));
                        }
                      },
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    // RaisedButton(
                    //   color: Colors.cyan,
                    //   child: Text("Open from Asset"),
                    //   onPressed: () {
                    //     if (assetPDFPath != null) {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) =>
                    //                   PdfViewPage(path: assetPDFPath)));
                    //     }
                    //   },
                    // )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key key, this.path}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Document"),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            nightMode: false,
            onError: (e) {
              print(e);
            },
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages;
                pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onPageChanged: (int page, int total) {
              setState(() {});
            },
            onPageError: (page, e) {},
          ),
          !pdfReady
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Offstage()
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _currentPage > 0
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  label: Text("Go to ${_currentPage - 1}"),
                  onPressed: () {
                    _currentPage -= 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
          _currentPage + 1 < _totalPages
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.green,
                  label: Text("Go to ${_currentPage + 1}"),
                  onPressed: () {
                    _currentPage += 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
        ],
      ),
    );
  }
}

// class _FirstScreenState extends State<FirstScreen> {
//   String urlPDFPath = "";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: NavDrawer(),
//       appBar: AppBar(
//         title: Text('Main Kaun Hu '),
//         backgroundColor: Colors.redAccent
//       ),
//       body: Container(
//         color: Colors.blue[100],
//         // child: Center(
//         //   child: Column(
//         //     mainAxisSize: MainAxisSize.max,
//         //     mainAxisAlignment: MainAxisAlignment.center,
//         //     children: <Widget>[
//         //       FlutterLogo(size: 150),
//         //       SizedBox(height: 50),
//         //       _signOutButton(),
//         //     ],
//         //   ),
//         // ),
//       ),
//     );
//   }

// Widget _signOutButton() {
//   return OutlineButton(
//     splashColor: Colors.grey,
//     onPressed: () {
//       signOutGoogle().whenComplete(() {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) {
//               return LoginPage();
//             },
//           ),
//         );
//       });
//     },
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//     highlightElevation: 0,
//     borderSide: BorderSide(color: Colors.grey),
//     child: Padding(
//       padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           //Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
//           Padding(
//             padding: const EdgeInsets.only(left: 10),
//             child: Text(
//               'Sign out with Google',
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.grey,
//               ),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

//}
