part of 'page_handler.dart';

class HomePage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.home_outlined);
  final Icon navBarIconSelected = const Icon(Icons.home);
  final String navBarTitle = 'Home';
  final BluetoothBuilder? ble;

  const HomePage({super.key, this.ble});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController firstRippleController;
  late AnimationController secondRippleController;
  late AnimationController thirdRippleController;
  late AnimationController centerCircleController;
  late Animation<double> firstRippleRadiusAnimation;
  late Animation<double> firstRippleOpacityAnimation;
  late Animation<double> firstRippleWidthAnimation;
  late Animation<double> secondRippleRadiusAnimation;
  late Animation<double> secondRippleOpacityAnimation;
  late Animation<double> secondRippleWidthAnimation;
  late Animation<double> thirdRippleRadiusAnimation;
  late Animation<double> thirdRippleOpacityAnimation;
  late Animation<double> thirdRippleWidthAnimation;
  late Animation<double> centerCircleRadiusAnimation;

  BluetoothBuilder? ble;
  bool isConnecting = false;

  @override
  void initState() {
    firstRippleController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    firstRippleRadiusAnimation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(
        parent: firstRippleController,
        curve: Curves.ease,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          firstRippleController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          firstRippleController.forward();
        }
      });

    firstRippleOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: firstRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
        () {
          setState(() {});
        },
      );

    firstRippleWidthAnimation = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: firstRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
        () {
          setState(() {});
        },
      );

    secondRippleController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    secondRippleRadiusAnimation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(
        parent: secondRippleController,
        curve: Curves.ease,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          secondRippleController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          secondRippleController.forward();
        }
      });

    secondRippleOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: secondRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
        () {
          setState(() {});
        },
      );

    secondRippleWidthAnimation = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: secondRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
        () {
          setState(() {});
        },
      );

    thirdRippleController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    thirdRippleRadiusAnimation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(
        parent: thirdRippleController,
        curve: Curves.ease,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          thirdRippleController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          thirdRippleController.forward();
        }
      });

    thirdRippleOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: thirdRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
        () {
          setState(() {});
        },
      );

    thirdRippleWidthAnimation = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: thirdRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
        () {
          setState(() {});
        },
      );

    centerCircleController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    centerCircleRadiusAnimation = Tween<double>(begin: 35, end: 50).animate(
      CurvedAnimation(
        parent: centerCircleController,
        curve: Curves.fastOutSlowIn,
      ),
    )
      ..addListener(
        () {
          setState(() {});
        },
      )
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            centerCircleController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            centerCircleController.forward();
          }
        },
      );

    firstRippleController.forward();
    Timer(
      const Duration(milliseconds: 765),
      () => secondRippleController.forward(),
    );

    Timer(
      const Duration(milliseconds: 1050),
      () => thirdRippleController.forward(),
    );

    centerCircleController.forward();

    super.initState();
  }

  @override
  void dispose() {
    firstRippleController.dispose();
    secondRippleController.dispose();
    thirdRippleController.dispose();
    centerCircleController.dispose();
    super.dispose();
  }

  String info = '>_';
  int infoCode = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /// ### [statusCode]
  /// * -2 = Crash (pink-purple)
  /// * -1 = Error (red)
  /// * 1 = Warning (yellow)
  /// * 2 = Success (green)
  /// * 3 = Info (blue)
  void msg(String m, [int statusCode = 0]) {
    setState(() {
      info = m;
      infoCode = statusCode;
    });
  }

  CircularProgressIndicator progressAnimation = const CircularProgressIndicator();

  @override
  Widget build(BuildContext context) {
    List infoMsg = Provider.of<CallbackProvider>(context, listen: true).infoMsg;
    bool isBLEConnected = Provider.of<ConnectionProvider>(context, listen: true).isConnected;
    msg(infoMsg.first, infoMsg.last);

    if (isBLEConnected) {
      setState(() {
        isConnecting = false;
      });
    }

    SizedBox connectAnimation = SizedBox(
      width: 110.0,
      height: 110.0,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: GestureDetector(
          onTap: () {
            var rng = Random();
            print(rng.nextInt(50));

            //     Provider.of<ConnectionProvider>(context, listen: false).toggle(true);
            //     setState(() {
            //       isConnecting = true;
            //     });
          },
          child: CustomPaint(
            painter: MyPainter(
              firstRippleRadiusAnimation.value,
              firstRippleOpacityAnimation.value,
              firstRippleWidthAnimation.value,
              secondRippleRadiusAnimation.value,
              secondRippleOpacityAnimation.value,
              secondRippleWidthAnimation.value,
              thirdRippleRadiusAnimation.value,
              thirdRippleOpacityAnimation.value,
              thirdRippleWidthAnimation.value,
              centerCircleRadiusAnimation.value,
              Theme.of(context).colorScheme.tertiaryContainer,
            ),
            size: const Size(600.0, 600.0),
            child: Container(),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        // child: InkWell(
        //   splashColor: Colors.transparent,
        //   highlightColor: Colors.transparent,
        //   onTap: () {
        //     Provider.of<ConnectionProvider>(context, listen: false).toggle(true);
        //     setState(() {
        //       isConnecting = true;
        //     });
        //   },
        child: isConnecting ? progressAnimation : connectAnimation,
        // ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double firstRippleRadius;
  final double firstRippleOpacity;
  final double firstRippleStrokeWidth;
  final double secondRippleRadius;
  final double secondRippleOpacity;
  final double secondRippleStrokeWidth;
  final double thirdRippleRadius;
  final double thirdRippleOpacity;
  final double thirdRippleStrokeWidth;
  final double centerCircleRadius;

  final Color myColor;

  MyPainter(
    this.firstRippleRadius,
    this.firstRippleOpacity,
    this.firstRippleStrokeWidth,
    this.secondRippleRadius,
    this.secondRippleOpacity,
    this.secondRippleStrokeWidth,
    this.thirdRippleRadius,
    this.thirdRippleOpacity,
    this.thirdRippleStrokeWidth,
    this.centerCircleRadius,
    this.myColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = myColor;

    Paint firstPaint = Paint();
    firstPaint.color = myColor.withOpacity(firstRippleOpacity);
    firstPaint.style = PaintingStyle.stroke;
    firstPaint.strokeWidth = firstRippleStrokeWidth;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), firstRippleRadius, firstPaint);

    Paint secondPaint = Paint();
    secondPaint.color = myColor.withOpacity(secondRippleOpacity);
    secondPaint.style = PaintingStyle.stroke;
    secondPaint.strokeWidth = secondRippleStrokeWidth;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), secondRippleRadius, secondPaint);

    Paint thirdPaint = Paint();
    thirdPaint.color = myColor.withOpacity(thirdRippleOpacity);
    thirdPaint.style = PaintingStyle.stroke;
    thirdPaint.strokeWidth = thirdRippleStrokeWidth;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), thirdRippleRadius, thirdPaint);

    Paint fourthPaint = Paint();
    fourthPaint.color = myColor;
    fourthPaint.style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), centerCircleRadius, fourthPaint);

    TextSpan span = TextSpan(
      style: GoogleFonts.bebasNeue(fontSize: 20),
      text: 'Connect',
    );
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
