/// Dart imports
import 'dart:async';
import 'dart:math' as math;

/// Package imports
import 'package:flutter/material.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

/// Renders the realtime line chart sample.
class LiveLineChart3D extends StatefulWidget {
  const LiveLineChart3D({super.key});

  final Icon navBarIcon = const Icon(Icons.poll_outlined);
  final Icon navBarIconSelected = const Icon(Icons.poll);
  final String navBarTitle = 'Live Line Chart';

  @override
  State<LiveLineChart3D> createState() => _LiveLineChart3DState();
}

/// State class of the realtime line chart.
class _LiveLineChart3DState extends State<LiveLineChart3D> {
  _LiveLineChart3DState() {
    timer = Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
  }

  Timer? timer;
  List<_ChartData>? chartData;
  late int count;
  ChartSeriesController? xAxisController;
  ChartSeriesController? yAxisController;
  ChartSeriesController? zAxisController;

  @override
  void initState() {
    count = 19;
    chartData = <_ChartData>[];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _buildLiveLineChart()));
  }

  /// Returns the realtime Cartesian line chart.
  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      series: <LineSeries<_ChartData, int>>[
        LineSeries<_ChartData, int>(
          onRendererCreated: (ChartSeriesController controller) {
            xAxisController = controller;
          },
          dataSource: chartData!,
          color: const Color.fromRGBO(192, 108, 132, 1),
          xValueMapper: (_ChartData data, _) => data.t,
          yValueMapper: (_ChartData data, _) => data.x,
          animationDuration: 0,
        ),
        LineSeries<_ChartData, int>(
          onRendererCreated: (ChartSeriesController controller) {
            yAxisController = controller;
          },
          dataSource: chartData!,
          color: const Color.fromARGB(255, 59, 101, 185),
          xValueMapper: (_ChartData data, _) => data.t,
          yValueMapper: (_ChartData data, _) => data.y,
          animationDuration: 0,
        ),
        LineSeries<_ChartData, int>(
          onRendererCreated: (ChartSeriesController controller) {
            zAxisController = controller;
          },
          dataSource: chartData!,
          color: const Color.fromARGB(255, 59, 185, 93),
          xValueMapper: (_ChartData data, _) => data.t,
          yValueMapper: (_ChartData data, _) => data.z,
          animationDuration: 0,
        )
      ],
    );
  }

  ///Continously updating the data source based on timer
  void _updateDataSource(Timer timer) {
    chartData!.add(_ChartData(count, _getRandomInt(10, 50), _getRandomInt(2, 10), _getRandomInt(5, 20)));
    if (chartData!.length == 30) {
      chartData!.removeAt(0);
      xAxisController?.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
        removedDataIndexes: <int>[0],
      );
      yAxisController?.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
        removedDataIndexes: <int>[0],
      );
      zAxisController?.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      xAxisController?.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
      );
      yAxisController?.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
      );
      zAxisController?.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
      );
    }
    count = count + 1;
  }

  ///Get the random data
  int _getRandomInt(int min, int max) {
    final math.Random random = math.Random();
    return min + random.nextInt(max - min);
  }
}

/// Private calss for storing the chart series data points.
class _ChartData {
  _ChartData(this.t, [this.x = 0, this.y = 0, this.z = 0]);
  final int t;
  final num x;
  final num y;
  final num z;
}
