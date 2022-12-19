import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
      home: const FPSWidget(
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showFirst = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: AnimatedCrossFade(
          duration: const Duration(seconds: 2),
          firstChild: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            height: 200,
            width: 200,
          ),
          secondChild: _ListWidget(),
          crossFadeState: showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showFirst = !showFirst;
          });
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _ListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(color: Colors.primaries[index % Colors.primaries.length], boxShadow: const [
            BoxShadow(
              color: Colors.green,
              offset: Offset(8, 12),
              blurRadius: 16,
            ),
          ]),
        ),
      ),
    );
  }
}

extension _FPS on Duration {
  double get fps => (1000 / inMilliseconds);
}

class FPSWidget extends StatefulWidget {
  final Widget child;

  final Alignment alignment;

  final bool show;

  const FPSWidget({
    Key? key,
    required this.child,
    this.show = true,
    this.alignment = Alignment.topRight,
  }) : super(key: key);

  @override
  _FPSWidgetState createState() => _FPSWidgetState();
}

class _FPSWidgetState extends State<FPSWidget> {
  Duration? prev;
  List<Duration> timings = [];
  double width = 150;
  double height = 100;
  late int framesToDisplay = width ~/ 5;

  @override
  void initState() {
    SchedulerBinding.instance?.addPostFrameCallback(update);
    super.initState();
  }

  update(Duration duration) {
    setState(() {
      if (prev != null) {
        timings.add(duration - prev!);
        if (timings.length > framesToDisplay) {
          timings = timings.sublist(timings.length - framesToDisplay - 1);
        }
      }

      prev = duration;
    });

    if (mounted && widget.show) {
      SchedulerBinding.instance?.addPostFrameCallback(update);
    }
  }

  @override
  void didUpdateWidget(covariant FPSWidget oldWidget) {
    if (oldWidget.show && !widget.show) {
      prev = null;
    }

    if (!oldWidget.show && widget.show) {
      SchedulerBinding.instance?.addPostFrameCallback(update);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: widget.alignment,
        children: [
          widget.child,
          if (widget.show)
            Padding(
              padding: const EdgeInsets.only(top: 60, right: 20),
              child: Container(
                height: height,
                width: width + 17,
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xaa000000),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (timings.isNotEmpty)
                      Text(
                        'FPS: ${timings.last.fps.toStringAsFixed(0)}',
                        style: const TextStyle(color: Color(0xffffffff)),
                      ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: SizedBox(
                        width: width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...timings.map((timing) {
                              final p = (timing.fps / 60).clamp(0.0, 1.0);

                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: 1.0,
                                ),
                                child: Container(
                                  color: Color.lerp(
                                    const Color(0xfff44336),
                                    const Color(0xff4caf50),
                                    p,
                                  ),
                                  width: 4,
                                  height: p * height,
                                ),
                              );
                            })
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
