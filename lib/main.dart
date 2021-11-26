import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late bool _loading;
  File? _image;
  List? _outputs;
  final _imagePicker = ImagePicker();

  void initState(){
    super.initState();
    _loading = true;

    loadModel().then((value){
      setState(() {
        _loading = false;
      });
    });

  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  pickImage() async {
    var image = await _imagePicker.getImage(source: ImageSource.gallery);
    if(image==null){
      return null;
    }
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(_image!);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.0,
      imageStd: 127.0,
    );

    setState(() {
      _loading = false;
      _outputs = output!;
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Breed Classifier'),
      ),
      body: _loading ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ) : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Container()
                : Container(
              child: Image.file(_image!),
              height: 500,
              width: MediaQuery.of(context).size.width-200,
            ),
            SizedBox(height: 20,),
            _outputs!=null ? Text("${_outputs![0]["label"]}".replaceAll(RegExp(r'[0-9]'), ''),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold
              ),
            )
                : Text('classification waiting')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}










































