import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:tflite/tflite.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(new MaterialApp(
      title: "corona",
      home: LandingScreen(),
  ));
}

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}


class Post {
  int statusCode;
  String statusMessage;
  String prediction;

  Post({
    final this.statusCode,
    final this.statusMessage,
    final this.prediction,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
     // statusCode: json['statusCode'],
     // statusMessage: json['statusMessage'],
      prediction: json['prediction'],
    );
  }
}

class _LandingScreenState extends State<LandingScreen> {
  File imageFile;
  String result;
  String path;

  _openGallery(BuildContext context) async{
    var picture= await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState((){
      imageFile=picture;
      path=picture.path;
    });
    Navigator.of(context).pop();
  }
  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
      path=picture.path;
    });
    Navigator.of(context).pop();
  }


  Widget _displayimage(String result){
    if(result==null)
      {
        return Text('Wait For atleast 15-20 seconds and then click on classify image button again!');
      }
    else
      {
        if(result=='1')
          {
            result = NULL ;
            print('corona positive');
            return Text('Corona Positive');
          }
        else
          {
            print('corona negative');
          return Text('Corona Negative');}
      }
  }


  final String phpEndPoint = 'https://covid-19-detect-1327.herokuapp.com/predict/android/';



  Future classifyImage() async{
    if(imageFile==null) return;
    //2,3List<int> imageBytes = imageFile.readAsBytesSync();
    //1
   //
     String base64Image = base64Encode(imageFile.readAsBytesSync());
    //3
    // String base64Image(List<int> bytes) => base64.encode(imageBytes);
    //4
    var encoded = Uri.encodeFull(base64Image);
    //2  String base64Image = base64Encode(imageBytes);

   // print(encoded);
    String fileName = imageFile.path.split("/").last;
   // print(fileName);
    http.post(phpEndPoint, body:
    {
      "image" : encoded,
      "name" : fileName,
    }).then((res) {
      print(res.body);
      print(res.statusCode);
     // var data = res.body;
      if (res.statusCode == 200){
        var temp = Post.fromJson(json.decode(res.body));

        result = temp.prediction;
        //if (res.body['prediction'] == '1' ) {
       // res.body.prediction;
        print(result);
      }

    }).catchError((err) {
      print(err);
    //print(base64Image);
    //print(fileName);
    });

   // _display();
  }

  //final String nodeEndPoint = '';

  Future<void> _showChoiceDialog(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context){
    return AlertDialog(
    title: Text("Make a Choose!"),
    content: SingleChildScrollView(
    child: ListBody(
    children: <Widget>[
    GestureDetector(
    child: Text("Gallery"),
    onTap: (){
    _openGallery(context);
    },
    ),
    Padding(padding: EdgeInsets.all(8.0)),
    GestureDetector(
    child: Text("Camera"),
    onTap: (){
    _openCamera(context);
    },
    )
    ],
    ),
    ),
    );
    });
  }

  Future<void> _display(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
       content : _displayimage(result),
      );
    });
  }


  Widget _decideImageView(){
    if(imageFile==null)
    {
      return Text("No Image Selected!");
    }else{
      return Image.file(imageFile,width: 400,height: 400);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CORONA DETECTION"),
      ),
      body: Container(
        child: Center (
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                _decideImageView(),
            RaisedButton(onPressed: (){
                  _showChoiceDialog(context);
      },child: Text("select image!"),),

                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: RaisedButton (
                      onPressed: () {
                        classifyImage();
                        _display(context);
                      },
                    child: Text('Classify Image'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  )),

                   // _display(result)
                //  result== null ? Text('result') : (result == '1' ? Text('Corona Posiitve') : Text('Corona Negative'))
      ],
    ),
    ),
    ),
    );
  }
}