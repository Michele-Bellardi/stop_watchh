import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const StopwatchApp());

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StopwatchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum StopwatchState { stopped, running, paused } //enum con gli stati che può assumere l'app

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late StreamController<int> _tickController; //Stream che emette i tick
  Stream<int>? _secondsStream; //Stream per convertire i tick in secondi

  Timer? _timer; //Contatore del cronometro

  StopwatchState _state = StopwatchState.stopped; //Stato in cui si trova il cronometro

  int _ticks = 0; //Contatore di ticks

  @override
  void initState() {
    super.initState();
    _tickController = StreamController<int>.broadcast(); //StreamController per inviare i tick

    _secondsStream = _tickController.stream.map((tick) => tick ~/ 10 /*ogni 10 tick = 1 secondo*/); //Quando arriva un tick viene trasformato in secondi
  }


  void _startTimer() { //Metodo per avviare il timer
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      _ticks++;
      _tickController.add(_ticks); //Per inviare il nuovo valore nello stream
    });
  }

  void _stopTimer() { //Metodo per fermare il timer e resettarlo
    _timer?.cancel();
    _ticks = 0;
    _tickController.add(_ticks); //Aggiornamento dello stream
  }

  void _pauseTimer() { //Metodo per mettere in pausa il timer
    _timer?.cancel();
  }

  void _resumeTimer() { //Metodo per far riprendere il timer dopo la pausa
    _startTimer();
  }

  void _onStartStopReset() {//Metodo per gestire la logica del pulsante START / STOP / RESET
    setState(() {
      switch (_state) {
        case StopwatchState.stopped:
          _startTimer();
          _state = StopwatchState.running;
          break;

        case StopwatchState.running:
          _stopTimer();
          _state = StopwatchState.stopped;
          break;

        case StopwatchState.paused:
          _stopTimer();
          _state = StopwatchState.stopped;
          break;
      }
    });
  }

  void _onPauseResume() { //Metodo per gestire la logica del pulsante PAUSE / RESUME
    setState(() {
      if (_state == StopwatchState.running) {
        _pauseTimer();
        _state = StopwatchState.paused;
      } else if (_state == StopwatchState.paused) {
        _resumeTimer();
        _state = StopwatchState.running;
      }
    });
  }

  @override
  void dispose() { //Metodo per pulire il timer: ferma il timer e chiude lo stream
    _timer?.cancel();
    _tickController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cronometro con Stream')),
      body: Center(
        child: StreamBuilder<int>(//Per ricostruire la UI ogni volta che arriva un nuovo evento
          stream: _secondsStream, //Stream che emette i secondi
          builder: (context, snapshot) {
            final seconds = snapshot.data ?? 0;

            //Calcolo minuti e secondi formattati
            final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
            final secs = (seconds % 60).toString().padLeft(2, '0');

            return Text(
              '$minutes:$secs', //Per impostare il formato MM:SS
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),

      //UI dei pulsanti in basso a destra
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //UI del pulsante START / STOP / RESET
            ElevatedButton(
              onPressed: _onStartStopReset,
              child: Text(
                _state == StopwatchState.stopped
                    ? 'START'
                    : _state == StopwatchState.running
                    ? 'STOP'
                    : 'RESET',
              ),
            ),

            const SizedBox(width: 16),

            //UI del pulsante PAUSE / RESUME
            ElevatedButton(
              onPressed:
              _state == StopwatchState.stopped ? null : _onPauseResume,
              child: Text(
                _state == StopwatchState.paused ? 'RESUME' : 'PAUSE',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
