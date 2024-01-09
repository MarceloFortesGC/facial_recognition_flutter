import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'face_detector_view.dart';

class FacialRecognitionInstructions extends StatelessWidget {
  const FacialRecognitionInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 42,
                  height: 60,
                  child: SvgPicture.asset(
                    'assets/sgvs/facial_scan.svg',
                    // ignore: deprecated_member_use
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: const Text(
                  'Validação Biométrica Facial',
                  textScaler: TextScaler.linear(1.5),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'Necessário para garantir acesso à funcionalidade desejada.',
                textScaler: TextScaler.linear(1.2),
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Recomendações:',
                textScaler: TextScaler.linear(1.4),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.transparent),
              Row(
                children: [
                  Icon(
                    Icons.sunny,
                    color: Colors.blueGrey,
                    size: 32,
                  ),
                  const VerticalDivider(color: Colors.grey),
                  Expanded(
                    child: const Text(
                      'Vá para um lugar bem iluminado',
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.transparent),
              Row(
                children: [
                  Icon(
                    Icons.tag_faces,
                    color: Colors.blueGrey,
                    size: 32,
                  ),
                  const VerticalDivider(color: Colors.grey),
                  Expanded(
                    child: const Text(
                      'Não use óculos de sol, boné, máscara ou qualquer coisa que possa cobrir o rosto',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaceDetectorView(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      // Raio da borda
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'Ok, entendi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Divider(color: Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }
}
