import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stopwatch/platform_alert.dart';

class StopWatch extends StatefulWidget {
  final String name;
  final String email;
  const StopWatch({super.key, required this.name, required this.email});

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  int milliseconds = 0;
  int seconds = 0;
  final itemHeight = 60.0;
  final scrollController = ScrollController();
  late Timer timer;
  final laps = <int>[];
  bool isTicking = false;

  void _onTick(Timer time) {
    if (mounted) {
      setState(() {
        milliseconds += 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        children: [
          Expanded(child: _buildCounter(context)),
          Expanded(child: _buildLapDisplay()),
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Lap ${laps.length + 1}',
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.white),
          ),
          Text(
            _secondsText(milliseconds),
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildControls()
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: isTicking ? null : _startTimer,
          child: const Text('Start'),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.yellow),
          ),
          onPressed: isTicking ? _lap : null,
          child: const Text('Lap'),
        ),
        SizedBox(width: 20),
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          onPressed: isTicking ? _stopTimer : null,
          child: const Text('Stop'),
        ),
      ],
    );
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), _onTick);
    setState(() {
      laps.clear();
      isTicking = true;
    });
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds seconds';
  }

  void _stopTimer() {
    timer.cancel();
    setState(() {
      isTicking = false;
    });
    final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    final alert = PlatformAlert(
      title: 'Run Completed!',
      message: 'Total Run Time is ${_secondsText(totalRuntime)}.',
    );
    alert.show(context);
  }

  void _lap() {
    scrollController.animateTo(
      itemHeight * laps.length,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });
  }

  Widget _buildLapDisplay() {
    return Scrollbar(
      child: ListView.builder(
        controller: scrollController,
        itemExtent: itemHeight,
        itemCount: laps.length,
        itemBuilder: (context, index) {
          final milliseconds = laps[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 50),
            title: Text('Lap ${index + 1}'),
            trailing: Text(_secondsText(milliseconds)),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    scrollController.dispose();
    super.dispose();
  }
}
