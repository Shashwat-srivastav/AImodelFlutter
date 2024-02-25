import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:tflite/tflite.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:velocity_x/velocity_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var t;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  final ImagePickerController image = Get.put(ImagePickerController());

  loadModel() async {
    await Tflite.loadModel(
        model: "lib/assets/model_unquant.tflite",
        labels: "lib/assets/labels.txt");
  }

  @override
  void dispose() {
    super.dispose();
  }

  detectImage(File img) async {
    var predict = await Tflite.runModelOnImage(
        path: img.path,
        numResults: 2,
        threshold: 0.8,
        imageMean: 127.5,
        imageStd: 127.5);
    print(predict);
    setState(() {
      t = predict;
      print(t);
    });
  }

  // runModel() async {} E:\vscode\ai\aimodel\lib\main.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          image.getImage();
          // runModel();
        },
        // onDoubleTap: () {
        //   detectImage(image.img);
        // },
        child: Obx(
          () => Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  image: image.pathof.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(image.pathof.toString())))
                      : null,
                  color: Colors.amberAccent[200],
                ),

                // color: Colors.amberAccent[200],
              ).centered(),
              TextButton(
                  onPressed: () {
                    detectImage(image.img);
                  },
                  child: "Predict".text.make()),
              t[0]["label"].toString().text.headline3(context).make()
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePickerController extends GetxController {
  RxString pathof = "".obs;
  late File img;
  Future getImage() async {
    final ImagePicker _pick = ImagePicker();
    final image = await _pick.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pathof.value = image.path.toString();
      img = File(pathof.value);
    }
  }
}
