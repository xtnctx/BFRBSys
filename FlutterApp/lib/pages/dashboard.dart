part of 'page_handler.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.restorationId});
  final String? restorationId;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate =
      RestorableDateTime(DateTime(2021, 7, 25));
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
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
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

  final List<DashboardChartData> chartData = [
    DashboardChartData('David', 25, const Color.fromRGBO(9, 0, 136, 1)),
    DashboardChartData('Steve', 38, const Color.fromRGBO(147, 0, 119, 1)),
    DashboardChartData('Jack', 34, const Color.fromRGBO(228, 0, 124, 1)),
    DashboardChartData('Others', 52, const Color.fromRGBO(255, 189, 57, 1))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Dashboard',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.bebasNeue(fontSize: 30),
                ),
                subtitle: Text(
                  'January',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.bebasNeue(fontSize: 18),
                ),
                trailing: IconButton(
                  iconSize: 30,
                  onPressed: () {
                    _restorableDatePickerRouteFuture.present();
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Data1',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.bebasNeue(fontSize: 20),
                            ),
                            Text(
                              'Data2',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.bebasNeue(fontSize: 20),
                            ),
                          ],
                        ),
                        Container(
                            width: 150.0,
                            height: 150.0,
                            child: SfCircularChart(series: <CircularSeries>[
                              // Renders doughnut chart
                              DoughnutSeries<DashboardChartData, String>(
                                  dataSource: chartData,
                                  pointColorMapper:
                                      (DashboardChartData data, _) =>
                                          data.color,
                                  xValueMapper: (DashboardChartData data, _) =>
                                      data.x,
                                  yValueMapper: (DashboardChartData data, _) =>
                                      data.y)
                            ]))
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Data3',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.bebasNeue(fontSize: 20),
                        ),
                        Text(
                          'Data4',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.bebasNeue(fontSize: 20),
                        ),
                        Text(
                          'Data5',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.bebasNeue(fontSize: 20),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardChartData {
  DashboardChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
