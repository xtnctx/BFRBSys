part of 'page_manager.dart';

class Dashboard extends StatefulWidget {
  final String? restorationId;
  final BluetoothBuilder? ble;
  const Dashboard({super.key, this.restorationId, this.ble});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with RestorationMixin {
  List<DashboardChartData> ydata = [];
  List<List<DashboardChartData>> weeksYData = [];
  List<int> buzzValues = [];
  double? buzzMean = 0.0;
  double? meanImprovement = 0.0;
  BluetoothBuilder? ble;
  StreamSubscription? isReceivingControllerStream;
  String plotOption = "weeks";
  int weekIndex = 0;
  int userSelectedDate = 0;
  bool hasData = false;
  var rng = Random();

  late TrackballBehavior _trackballBehavior;
  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: true,
      // tooltipSettings: const InteractiveTooltip(enable: true, color: Colors.red),
      builder: (BuildContext context, TrackballDetails trackballDetails) {
        return Container(
          height: 50,
          width: 150,
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 8, 22, 0.75),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Row(
            children: [
              Center(
                  child: Container(
                      padding: EdgeInsets.only(top: 11, left: 7),
                      height: 40,
                      width: 100,
                      child: Text(
                          plotOption == 'month'
                              ? '${monthNames[_selectedDate.value.month - 1]} ${trackballDetails.point!.x.toString()} : Buzz: ${trackballDetails.point!.y.toString()}'
                              : 'Buzz: ${trackballDetails.point!.y.toString()}',
                          style: TextStyle(fontSize: 13, color: Color.fromRGBO(255, 255, 255, 1)))))
            ],
          ),
        );
      },
    );

    ble = widget.ble;
    listenReceiving();
    userSelectedDate = getDateInt(DateTime.now());
    callUpdateDashboard(userSelectedDate, plotOption);
    double x = DateTime(
      int.parse(userSelectedDate.toString().substring(0, 4)),
      int.parse(userSelectedDate.toString().substring(4, 6)) + 1,
      0,
    ).day.toDouble();
    print('x: $hasData');
    super.initState();
  }

  int getDateInt(dynamic input) {
    if (input.runtimeType == DateTime) {
      String formattedMonth = input.month.toString().padLeft(2, '0');
      String formattedDay = input.day.toString().padLeft(2, '0');
      String formattedDate = "${input.year}$formattedMonth$formattedDay";
      return int.parse(formattedDate);
    } else if (input.runtimeType == String) {
      return int.parse(input);
    } else {
      return -1;
    }
  }

  void callUpdateDashboard(int date, String plotOption) async {
    bool val = await updateDashboard(date, plotOption);
    setState(() {
      hasData = val;
    });
  }

  @override
  void dispose() {
    isReceivingControllerStream!.cancel();
    isReceivingControllerStream = null;
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2024),
          lastDate: DateTime(2100),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) async {
    if (newSelectedDate != null) {
      _selectedDate.value = newSelectedDate;
      int year = _selectedDate.value.year;
      String month = _selectedDate.value.month.toString().padLeft(2, '0');
      String day = _selectedDate.value.day.toString().padLeft(2, '0');
      String formattedDate = '$year$month$day';
      userSelectedDate = getDateInt(formattedDate);

      bool val = await updateDashboard(userSelectedDate, plotOption);
      setState(() {
        hasData = val;
        if (val) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Selected: $month/$day/$year'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Empty data.'),
          ));
        }
      });
    }
  }

  void listenReceiving() {
    isReceivingControllerStream = ble!.isReceivingController.stream.asBroadcastStream().listen((bool value) {
      // value = [String callbackMessage, double sendingProgress ,int statusCode]
      Provider.of<ConnectionProvider>(context, listen: false).setReceiving = value;
    });
  }

  void requestUpdate(String request) async {
    if (ble != null && ble!.isConnected && !ble!.isFileTransferInProgress) {
      setState(() {
        ble!.dashboardData = "";
        ble!.isReceivingController.add(true);
      });
      var user = await UserSecureStorage.getUser();
      String username = user['username'];

      // Get current date
      DateTime currentDate = DateTime.now();
      String formattedMonth = currentDate.month.toString().padLeft(2, '0');
      String formattedDay = currentDate.day.toString().padLeft(2, '0');
      String formattedDate = "${currentDate.year}$formattedMonth$formattedDay";

      var fileContents = utf8.encode('xupdaterequestx-$username-$request-$formattedDate-') as Uint8List;
      print("fileContents length is ${fileContents.length}");
      ble?.transferFile(fileContents);
    }
  }

  List<List<DashboardChartData>> monthToPerWeek(List<DashboardChartData> data) {
    List<List<DashboardChartData>> perWeek = [];
    List week = [];

    for (var val in data) {
      week.add(val);
      if (week.length == 7 || val == data.last) {
        perWeek.add(List.from(week));
        week.clear();
      }
    }

    if (perWeek.last.length < 4) {
      List y = perWeek.removeLast();
      for (var val in y) {
        perWeek.last.add(val);
      }
      return perWeek;
    }
    return perWeek;
  }

  void generateNullYs() {
    double maxMonthDay = DateTime(_selectedDate.value.year, _selectedDate.value.month + 1, 0).day.toDouble();

    List<DashboardChartData> nullYValues = [];
    for (int day = 0; day < maxMonthDay; day++) {
      DashboardChartData chartData = DashboardChartData(day + 1, null);
      nullYValues.add(chartData);
    }
    setState(() {
      weeksYData.clear();
      weeksYData = monthToPerWeek(nullYValues);
      buzzMean = null;
      meanImprovement = null;
    });
  }

  Future<bool> updateDashboard(int selectedDate, String plotOption) async {
    String dir = await AppStorage.getDir();
    List<io.FileSystemEntity> dataFile = io.Directory(dir).listSync();
    // String fileRead = io.File("$dir/ryan.json").readAsStringSync();

    Map<String, dynamic> jsonData = json.decode(fileRead);
    List jsonDataList = jsonData["data"];
    List<Map<String, dynamic>> dataList = jsonDataList.cast<Map<String, dynamic>>();

    int selectedMonth = selectedDate ~/ 100;
    int selectedDay = selectedDate % 100;

    if (plotOption == 'weeks') {
      List<DashboardChartData> monthData = [];

      for (Map<String, dynamic> item in dataList) {
        int datetime = int.parse(item["datetime"]);
        int yearMonth = datetime ~/ 100;
        int day = datetime % 100;
        if (selectedMonth == yearMonth) {
          DashboardChartData chartData = DashboardChartData(day, item["buzz"]);
          monthData.add(chartData);
        }
      }
      if (monthData.isNotEmpty) {
        setState(() {
          weeksYData = monthToPerWeek(monthData);
        });
        // find date in selected month
        for (int i = 0; i < weeksYData.length; i++) {
          for (int j = 0; j < weeksYData[i].length; j++) {
            if (weeksYData[i][j].x == selectedDay) {
              setState(() {
                weekIndex = i;
              });
              break;
            }
          }
        }
        updateImprovementAndAverage();
        return true;
      } else {
        generateNullYs();
        return false;
      }
    } else if (plotOption == 'month') {
      setState(() {
        ydata.clear();
        for (Map<String, dynamic> item in dataList) {
          int datetime = int.parse(item["datetime"]);
          int yearMonth = datetime ~/ 100;
          int day = datetime % 100;
          if (selectedMonth == yearMonth) {
            DashboardChartData chartData = DashboardChartData(day, item["buzz"]);
            ydata.add(chartData);
          }
        }

        // Improvement
        buzzValues.clear();
        buzzValues = ydata.map((data) => data.y!).toList();
        List<double> improvements = calculateImprovement(buzzValues);
        meanImprovement = calculateMean(improvements);

        // Average Buzz
        List<double> buzzValuesDouble = buzzValues.map((intNumber) => intNumber.toDouble()).toList();
        buzzMean = calculateMean(buzzValuesDouble);
      });
      if (ydata.isNotEmpty) {
        return true;
      } else {
        setState(() {
          buzzMean = null;
          meanImprovement = null;
        });
      }
    }
    return false;
  }

  void updateImprovementAndAverage() {
    // Improvement
    buzzValues.clear();
    buzzValues = weeksYData[weekIndex].map((data) => data.y!).toList();
    List<double> improvements = calculateImprovement(buzzValues);
    meanImprovement = calculateMean(improvements);

    // Average Buzz
    List<double> buzzValuesDouble = buzzValues.map((intNumber) => intNumber.toDouble()).toList();
    buzzMean = calculateMean(buzzValuesDouble);
  }

  Widget getIconBasedOnNumber(double? number) {
    if (number == null) {
      return const Icon(Icons.drag_handle, size: 35);
    }
    return number < 0
        ? const Icon(Icons.keyboard_double_arrow_down, color: Color.fromARGB(255, 193, 59, 49), size: 35)
        : number > 0
            ? const Icon(Icons.keyboard_double_arrow_up, color: Color.fromARGB(255, 42, 163, 50), size: 35)
            : const Icon(Icons.drag_handle, size: 35);
  }

  int getPlotOptionValue(String plotOption, int maxMonthDay) {
    if (plotOption == 'weeks') {
      return 1;
    } else if (plotOption == 'month') {
      if (maxMonthDay == 28) {
        return 3;
      } else if (maxMonthDay == 29) {
        return 4;
      } else if (maxMonthDay == 30) {
        return 5;
      } else if (maxMonthDay == 31) {
        return 5;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isReceiving = Provider.of<ConnectionProvider>(context, listen: true).isReceiving;
    double maxMonthDay = DateTime(_selectedDate.value.year, _selectedDate.value.month + 1, 0).day.toDouble();
    double cardHeight = 220.0;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context).colorScheme.tertiaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.20, 0.45]),
          ),
          height: MediaQuery.of(context).size.height * .40,
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Dashboard',
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 30),
              ),
              subtitle: Text(
                plotOption == 'month'
                    ? '${monthNames[_selectedDate.value.month - 1]} ${_selectedDate.value.year}'
                    : '${monthNames[_selectedDate.value.month - 1]} ${_selectedDate.value.year} - week ${weekIndex + 1}',
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 20),
              ),
              trailing: isReceiving
                  ? const CircularProgressIndicator()
                  : PopupMenuButton(
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text("View profile"),
                        ),
                        PopupMenuItem(
                          child: Text("View as: ${plotOption == 'month' ? 'weeks' : 'month'}"),
                          onTap: () async {
                            setState(() {
                              if (plotOption == 'month') {
                                plotOption = 'weeks';
                              } else if (plotOption == 'weeks') {
                                plotOption = 'month';
                              }
                            });
                            bool val = await updateDashboard(userSelectedDate, plotOption);
                            setState(() {
                              hasData = val;
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Text("Update"),
                          onTap: () {
                            requestUpdate("all");
                          },
                        ),
                        PopupMenuItem(
                          child: const Text("Refresh"),
                          onTap: () async {
                            bool val = await updateDashboard(userSelectedDate, plotOption);
                            setState(() {
                              hasData = val;
                            });
                          },
                        ),
                      ],
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('images/ekusuuuu-calibaaaaaaaaaaaaa.png'),
                      ),
                      onSelected: (String value) {
                        if (value == 'profile') {
                          Navigator.pushNamed(context, '/profile');
                        }
                        // Handle other menu items if needed
                      },
                    ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * .24,
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
            ),
            // height: MediaQuery.of(context).size.height,
          ),
        ),

        // The card widget with top padding,
        // incase if you wanted bottom padding to work,
        // set the `alignment` of container to Alignment.bottomCenter
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .12, right: 20.0, left: 20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width * 0.86,
                    child: GestureDetector(
                      onHorizontalDragEnd: plotOption == 'weeks' && hasData
                          ? (DragEndDetails details) {
                              if (details.primaryVelocity! > 0) {
                                // Swiped to the right
                                if (weekIndex > 0) {
                                  setState(() {
                                    weekIndex -= 1;
                                    updateImprovementAndAverage();
                                  });
                                }
                              } else if (details.primaryVelocity! < 0) {
                                // Swiped to the left
                                // weeksYData.length = 5
                                if (weekIndex < weeksYData.length - 1) {
                                  setState(() {
                                    weekIndex += 1;
                                    updateImprovementAndAverage();
                                  });
                                }
                              }
                            }
                          : null,
                      child: Card(
                        shadowColor: Theme.of(context).colorScheme.shadow,
                        elevation: 5.0,
                        child: SfCartesianChart(
                          trackballBehavior: _trackballBehavior,
                          plotAreaBorderWidth: 0,
                          primaryXAxis: NumericAxis(
                            isVisible: true,
                            interval: getPlotOptionValue(plotOption, maxMonthDay.toInt()).toDouble(),
                            labelStyle: GoogleFonts.bebasNeue(fontSize: 12),
                            maximum: plotOption == 'month' ? maxMonthDay : null,
                          ),
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          series: <ChartSeries>[
                            // Renders line chart
                            AreaSeries<DashboardChartData, int>(
                              dataSource: plotOption == 'month' ? ydata : weeksYData[weekIndex],
                              color: Theme.of(context).colorScheme.primary,
                              xValueMapper: (DashboardChartData data, _) => data.x,
                              yValueMapper: (DashboardChartData data, _) => data.y,
                            ),
                            // FastLineSeries<ChartData, int>(
                            //     dataSource: dropdownValue == 'Accuracy' ? valAccuracy : valLoss,
                            //     color: CustomColor.validationLineColor,
                            //     xValueMapper: (ChartData data, _) => data.x,
                            //     yValueMapper: (ChartData data, _) => data.y),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: cardHeight,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      elevation: 5.0,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: cardHeight * .05, left: cardHeight * .05),
                              child: getIconBasedOnNumber(meanImprovement),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                child: Text(
                                  meanImprovement != null ? '${meanImprovement!.toStringAsFixed(2)}%' : '--',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.bebasNeue(fontSize: 50),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Improvement',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.bebasNeue(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: cardHeight,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      elevation: 5.0,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: cardHeight * .05, left: cardHeight * .05),
                              child: const Icon(
                                Icons.line_weight,
                                size: 35,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                child: Text(
                                  buzzMean != null ? buzzMean!.toStringAsFixed(2) : '--',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.bebasNeue(fontSize: 50),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Average Buzz',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.bebasNeue(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: SizedBox(height: 1),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 60, right: 60),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        onPressed: () {
                          _restorableDatePickerRouteFuture.present();
                        },
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 35,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                'Calendar',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.bebasNeue(fontSize: 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(height: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) => Scaffold(
  //       appBar: AppBar(
  //         title: Text('App Title', style: TextStyle(color: Colors.white)),
  //         backgroundColor: Color.fromARGB(255, 18, 32, 47),
  //         elevation: 0,
  //       ),
  //       body: ClipRRect(
  //         borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
  //         child: Container(
  //           color: Colors.white,
  //           child: Center(
  //             child: Text(
  //               'App Content',
  //             ),
  //           ),
  //         ),
  //       ),
  //     );

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(),
  //     body: Center(
  //       child: Column(
  //         children: [
  //           const SizedBox(height: 10),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //             child: ListTile(
  //               contentPadding: EdgeInsets.zero,
  //               title: Text(
  //                 'Dashboard',
  //                 textAlign: TextAlign.left,
  //                 style: GoogleFonts.bebasNeue(fontSize: 30),
  //               ),
  //               subtitle: Text(
  //                 'January',
  //                 textAlign: TextAlign.left,
  //                 style: GoogleFonts.bebasNeue(fontSize: 18),
  //               ),
  //               trailing: IconButton(
  //                 iconSize: 30,
  //                 onPressed: () {
  //                   _restorableDatePickerRouteFuture.present();
  //                 },
  //                 icon: const Icon(Icons.calendar_month_outlined),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //               color: Theme.of(context).colorScheme.primary,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Column(
  //                         children: [
  //                           Text(
  //                             'Data1',
  //                             textAlign: TextAlign.left,
  //                             style: GoogleFonts.bebasNeue(fontSize: 20),
  //                           ),
  //                           Text(
  //                             'Data2',
  //                             textAlign: TextAlign.left,
  //                             style: GoogleFonts.bebasNeue(fontSize: 20),
  //                           ),
  //                         ],
  //                       ),
  //                       Container(
  //                           width: 150.0,
  //                           height: 150.0,
  //                           child: SfCircularChart(series: <CircularSeries>[
  //                             // Renders doughnut chart
  //                             DoughnutSeries<DashboardChartData, String>(
  //                                 dataSource: chartData,
  //                                 pointColorMapper: (DashboardChartData data, _) => data.color,
  //                                 xValueMapper: (DashboardChartData data, _) => data.x,
  //                                 yValueMapper: (DashboardChartData data, _) => data.y)
  //                           ]))
  //                     ],
  //                   ),
  //                   const Divider(),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       Text(
  //                         'Data3',
  //                         textAlign: TextAlign.left,
  //                         style: GoogleFonts.bebasNeue(fontSize: 20),
  //                       ),
  //                       Text(
  //                         'Data4',
  //                         textAlign: TextAlign.left,
  //                         style: GoogleFonts.bebasNeue(fontSize: 20),
  //                       ),
  //                       Text(
  //                         'Data5',
  //                         textAlign: TextAlign.left,
  //                         style: GoogleFonts.bebasNeue(fontSize: 20),
  //                       ),
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class DashboardChartData {
  DashboardChartData(this.x, this.y);
  final int x;
  final int? y;
}
