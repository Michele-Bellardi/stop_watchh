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

enum StopwatchState { stopped, running, paused }

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late StreamController<int> _tickController;
  Stream<int>? _secondsStream;
  Timer? _timer;

  StopwatchState _state = StopwatchState.stopped;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _tickController = StreamController<int>.broadcast();
    _secondsStream = _tickController.stream.map((tick) => tick ~/ 10);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      _ticks++;
      _tickController.add(_ticks);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _ticks = 0;
    _tickController.add(_ticks);
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _onStartStopReset() {
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

  void _onPauseResume() {
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
  void dispose() {
    _timer?.cancel();
    _tickController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cronometro con Stream')),
      body: Center(
        child: StreamBuilder<int>(
          stream: _secondsStream,
          builder: (context, snapshot) {
            final seconds = snapshot.data ?? 0;
            final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
            final secs = (seconds % 60).toString().padLeft(2, '0');
            return Text(
              '$minutes:$secs',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
            ElevatedButton(
              onPressed: _state == StopwatchState.stopped ? null : _onPauseResume,
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
