import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  StateMachineController? controller;
  Artboard? _artboard;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  int _rating = 0;
  Timer? _resetTimer;

  void _onRiveInit(Artboard artboard) {
    _artboard = artboard;
    controller = StateMachineController.fromArtboard(artboard, "Login Machine");
    if (controller == null) return;

    artboard.addController(controller!);

    trigSuccess = controller!.findSMI("trigSuccess");
    trigFail = controller!.findSMI("trigFail");
  }

  void _setRating(int value) {
    setState(() => _rating = value);

    // Cancela cualquier timer previo
    _resetTimer?.cancel();

    // Dispara la animación correspondiente
    if (value >= 4) {
      trigSuccess?.fire(); // feliz 😄
    } else if (value <= 2) {
      trigFail?.fire(); // triste 😢
    }

    // 🔁 Reinicia la animación a su estado neutral después de un corto tiempo
    _resetTimer = Timer(const Duration(milliseconds: 1000), () {
      if (_artboard != null) {
        final machineName = "Login Machine";
        final newController = StateMachineController.fromArtboard(_artboard!, machineName);
        if (newController != null) {
          _artboard!
            ..removeController(controller!)
            ..addController(newController);
          controller = newController;
          trigSuccess = controller!.findSMI("trigSuccess");
          trigFail = controller!.findSMI("trigFail");
        }
      }
    });
  }

  Widget _buildStar(int index) {
    final isActive = index <= _rating;
    return IconButton(
      icon: Icon(Icons.star, color: isActive ? Colors.amber : Colors.grey.shade400, size: 42),
      onPressed: () => _setRating(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🧸 Animación del oso
              SizedBox(
                width: size.width,
                height: 250,
                child: RiveAnimation.asset("assets/animated_login_character.riv", stateMachines: ["Login Machine"], onInit: _onRiveInit, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              const Text(
                "Enjoying Souter?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),

              // ⭐ Fila de estrellas
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => _buildStar(i + 1))),
              const SizedBox(height: 20),

              SizedBox(
                width: size.width * 0.6,
                child: const Text(
                  "With how many stars do you rate your experience? Tap a star to rate!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color.fromARGB(136, 11, 11, 154)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
}
