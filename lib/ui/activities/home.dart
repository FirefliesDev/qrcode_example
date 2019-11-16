import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode_example/utils/colors_palette.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  final String title;

  Home({this.title});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey _qrCodeImageKey = new GlobalKey();
  bool _showQrCode = false;
  String _resultQrCode = "";
  static const channel = const MethodChannel('flutter.native/share');

  @override
  Widget build(BuildContext context) {
    return _buildScaffold();
  }

  /// Creates a Scaffold with body content.
  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        /// If [title] doens't has value, then set a default message.
        title: Text(widget.title == null ? 'Home' : widget.title),
      ),
      backgroundColor: ColorsPalette.backgroundColorLight,
      body: Column(
        children: <Widget>[
          Text(_resultQrCode),
          _buildFlatButton(
              name: 'Scan',
              color: ColorsPalette.accentColor,
              textColor: ColorsPalette.textColorLight,
              onTap: _scanQrCode),
          _buildFlatButton(
              name: 'Generate',
              color: ColorsPalette.accentColor,
              textColor: ColorsPalette.textColorLight,
              onTap: _generateQrCode),
          Visibility(
            child: _buildQrCode(value: 'My Custom QR Code.'),
            visible: _showQrCode,
          ),
        ],
      ),
    );
  }

  /// Scan QR Code
  Future<void> _scanQrCode() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        _resultQrCode = qrResult;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          _resultQrCode = "Camera permission was denied";
        });
      } else {
        setState(() {
          _resultQrCode = "Unknown Error: $e";
        });
      }
    } on FormatException {
      setState(() {
        _resultQrCode = "You pressed the back button before scanning anything";
      });
    } catch (e) {
      setState(() {
        _resultQrCode = "Unknown Error: $e";
      });
    }
  }

  /// Generate QR Code
  void _generateQrCode() {
    setState(() {
      this._showQrCode = true;
    });
  }

  /// Creates a flat button
  Widget _buildFlatButton(
      {String name, Color color, Color textColor, VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
            onPressed: onTap == null ? () {} : onTap,
            child: Text(
              name,
              style: TextStyle(color: textColor),
            ),
            textColor: ColorsPalette.textColorLight,
            color: color),
      ),
    );
  }

  /// Creates a QR Code
  Widget _buildQrCode({@required String value}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        onTap: _shareQrCode,
        child: RepaintBoundary(
          key: _qrCodeImageKey,
          child: Container(
            color: ColorsPalette.backgroundColorLight,
            child: QrImage(
              data: value,
              version: QrVersions.auto,
              size: 250,
              gapless: true,
            ),
          ),
          // ),
        ),
      ),
    );
  }

  // 
  Future<void> _shareQrCode() async {
    try {
      RenderRepaintBoundary boundary =
          _qrCodeImageKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      var file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      print('${tempDir.path}/image.png');

      await channel.invokeMethod('shareImage', {'path': 'image.png'});

    } catch (e) {
      print(e.toString());
    }
  }
}
