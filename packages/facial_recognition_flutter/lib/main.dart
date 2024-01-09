import 'package:flutter/material.dart';

import 'facial_recognition/facial_recognition_instructions.dart';
import 'facial_recognition/facial_recognition_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _provider = FacialRecognitionProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Módulo de Reconhecimento Facial'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Card(
                clipBehavior: Clip.hardEdge,
                color: Colors.blueGrey,
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.tag_faces_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Reconhecimento Facial',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  children: [
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FacialRecognitionInstructions(),
                          ),
                        );
                      },
                      child: Text('Acessar Função'),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Configurações',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaler: TextScaler.linear(1.2),
                    ),
                    CheckboxListTile(
                      value: _provider.getShowCoordinates,
                      title: Text(
                        'Mostrar coordenadas faciais',
                        style: TextStyle(color: Colors.white),
                      ),
                      onChanged: (e) {
                        setState(() {
                          _provider.setShowCoordinates = e!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      value: _provider.getShowPhotos,
                      title: Text(
                        'Mostrar fotos após captura',
                        style: TextStyle(color: Colors.white),
                      ),
                      onChanged: (e) {
                        setState(() {
                          _provider.setShowPhotos = e!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
