import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/timer_service.dart';

class TimerScreen extends StatefulWidget {
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TimerService timerService = TimerService();

  final goalController = TextEditingController();
  final minutesController = TextEditingController(text: '25');

  Timer? localTimer;
  int remainingSeconds = 1500;

  @override
  void dispose() {
    localTimer?.cancel();
    goalController.dispose();
    minutesController.dispose();
    super.dispose();
  }

  void startLocalCountdown() {
    localTimer?.cancel();

    localTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int calculateRemaining(Map<String, dynamic> data) {
    final isRunning = data['isRunning'] ?? false;
    final duration = data['durationSeconds'] ?? 1500;
    final pausedRemaining = data['pausedRemainingSeconds'] ?? duration;
    final startTime = data['startTime'];

    if (!isRunning || startTime == null || startTime is! Timestamp) {
      return pausedRemaining;
    }

    final startedAt = startTime.toDate();
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    final remaining = duration - elapsed;

    return remaining < 0 ? 0 : remaining;
  }

  Future<void> startTimer() async {
    final minutes = int.tryParse(minutesController.text.trim()) ?? 25;
    final durationSeconds = minutes * 60;

    await timerService.startTimer(
      durationSeconds: durationSeconds,
      goal: goalController.text.trim(),
    );
  }

  Future<void> pauseTimer() async {
    await timerService.pauseTimer(remainingSeconds);
    localTimer?.cancel();
  }

  Future<void> resetTimer() async {
    await timerService.resetTimer();
    localTimer?.cancel();

    setState(() {
      remainingSeconds = 1500;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shared Study Timer')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: timerService.getTimerStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading timer'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: ElevatedButton(
                onPressed: resetTimer,
                child: Text('Create Shared Timer'),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final isRunning = data['isRunning'] ?? false;
          final goal = data['goal'] ?? '';
          final startedBy = data['startedBy'] ?? 'Unknown';

          remainingSeconds = calculateRemaining(data);

          if (isRunning) {
            startLocalCountdown();
          } else {
            localTimer?.cancel();
          }

          return Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  formatTime(remainingSeconds),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),

                Text(
                  isRunning ? 'Timer Running' : 'Timer Paused',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),

                TextField(
                  controller: goalController,
                  decoration: InputDecoration(
                    labelText: 'Session Goal',
                    hintText: 'Example: Finish Chapter 5 notes',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),

                Text('Current Goal: ${goal.isEmpty ? 'No goal set' : goal}'),
                SizedBox(height: 6),
                Text('Started By: $startedBy'),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: startTimer,
                        child: Text('Start'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isRunning ? pauseTimer : null,
                        child: Text('Pause'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                ElevatedButton(onPressed: resetTimer, child: Text('Reset')),
              ],
            ),
          );
        },
      ),
    );
  }
}
