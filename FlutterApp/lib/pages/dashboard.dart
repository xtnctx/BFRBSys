part of 'page_handler.dart';

class Dashboard extends StatefulWidget {
  final String? restorationId;
  final BluetoothBuilder? ble;
  const Dashboard({super.key, this.restorationId, this.ble});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with RestorationMixin {
  List<DashboardChartData> ydata = [];
  BluetoothBuilder? ble;
  StreamSubscription? isReceivingControllerStream;

  var rng = Random();

  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
        // Enables the trackball
        enable: true,
        tooltipSettings: const InteractiveTooltip(enable: true, color: Colors.red));

    for (int row = 1; row < 30; row++) {
      ydata.add(DashboardChartData(row, rng.nextInt(50)));
    }
    ble = widget.ble;
    listenReceiving();
    super.initState();
  }

  @override
  void dispose() {
    isReceivingControllerStream!.cancel();
    isReceivingControllerStream = null;
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime(2021, 7, 25));
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
          firstDate: DateTime(2021),
          lastDate: DateTime(2022),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        ));
      });
    }
  }

  void listenReceiving() {
    isReceivingControllerStream = ble!.isReceivingController.stream.asBroadcastStream().listen((bool value) {
      // value = [String callbackMessage, double sendingProgress ,int statusCode]
      Provider.of<ConnectionProvider>(context, listen: false).setReceiving = value;
    });
  }

  void requestUpdateAll() async {
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

      var fileContents = utf8.encode('xupdaterequestx-$username-all-$formattedDate-') as Uint8List;
      print("fileContents length is ${fileContents.length}");
      ble?.transferFile(fileContents);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isReceiving = Provider.of<ConnectionProvider>(context, listen: true).isReceiving;

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
                'January 2024',
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 20),
              ),
              trailing: isReceiving
                  ? const CircularProgressIndicator()
                  : PopupMenuButton(
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupMenuItem>>[
                        PopupMenuItem(
                          child: const Text("View profile"),
                          onTap: () {
                            print("View profile");
                          },
                        ),
                        PopupMenuItem(
                          child: const Text("View as: per month"),
                          onTap: () {
                            print("View as: per month");
                          },
                        ),
                        PopupMenuItem(
                          child: const Text("Update"),
                          onTap: () {
                            requestUpdateAll();
                          },
                        ),
                        PopupMenuItem(
                          child: const Text("Refresh"),
                          onTap: () {
                            print(ble!.dashboardData);
                          },
                        ),
                      ],
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('images/ekusuuuu-calibaaaaaaaaaaaaa.png'),
                      ),
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
                    child: Card(
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      elevation: 5.0,
                      child: SfCartesianChart(
                        trackballBehavior: _trackballBehavior,
                        plotAreaBorderWidth: 0,
                        primaryXAxis: NumericAxis(
                          isVisible: false,
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        series: <ChartSeries>[
                          // Renders line chart
                          FastLineSeries<DashboardChartData, int>(
                              dataSource: ydata,
                              color: CustomColor.trainingLineColor,
                              xValueMapper: (DashboardChartData data, _) => data.x,
                              yValueMapper: (DashboardChartData data, _) => data.y),
                          // FastLineSeries<ChartData, int>(
                          //     dataSource: dropdownValue == 'Accuracy' ? valAccuracy : valLoss,
                          //     color: CustomColor.validationLineColor,
                          //     xValueMapper: (ChartData data, _) => data.x,
                          //     yValueMapper: (ChartData data, _) => data.y),
                        ],
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
                              child: const Icon(
                                Icons.keyboard_double_arrow_up,
                                color: Colors.green,
                                size: 35,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                child: Text(
                                  '2.12%',
                                  textAlign: TextAlign.left,
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
                                  '15.6',
                                  textAlign: TextAlign.left,
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
                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer),
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
  final int y;
}
