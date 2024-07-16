/* Copyright 2024 Ryan Christopher Bahillo. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=========================================================================*/

// ignore_for_file: avoid_print, non_constant_identifier_names

part of 'page_manager.dart';

class MonitoringPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.monitor_heart_outlined);
  final Icon navBarIconSelected = const Icon(Icons.monitor_heart);
  final String navBarTitle = 'Monitoring App';
  final BluetoothBuilder? ble;

  const MonitoringPage({super.key, this.ble});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  BluetoothBuilder? ble;
  bool isBuildingModel = false;
  String info = '>_';
  int infoCode = 0;

  Crc32 crc = Crc32();

  Timer? timer;
  Timer? onCaptureTimer;
  Timer? offCaptureTimer;
  Timer? loadingTextTimer;

  List<_ChartData>? chartAccData;
  List<_ChartData>? chartGyroData;
  late int count;
  ChartSeriesController? axAxisController;
  ChartSeriesController? ayAxisController;
  ChartSeriesController? azAxisController;

  ChartSeriesController? gxAxisController;
  ChartSeriesController? gyAxisController;
  ChartSeriesController? gzAxisController;

  int distance = 0;
  double temperature = 0.0;

  String? onTargetText;
  String? offTargetText;

  String? accData;
  String? gyroData;

  NeuralNetworkRequestBuild buildClass = NeuralNetworkRequestBuild();
  final TextEditingController _textController = TextEditingController();

  List<List<String>> dummyData = [
    ["ax", "ay", "az", "gx", "gy", "gz", "class"],
    ['0.574', '0.094', '-0.779', '1.465', '-0.061', '-0.732', '1'],
    ['0.575', '0.103', '-0.791', '1.648', '1.16', '-0.427', '1'],
    ['0.565', '0.115', '-0.796', '0.549', '0.61', '0.183', '1'],
    ['0.586', '0.113', '-0.79', '1.099', '4.395', '-0.366', '1'],
    ['0.579', '0.112', '-0.818', '1.526', '1.892', '-0.122', '1'],
    ['0.578', '0.125', '-0.826', '0.488', '1.709', '0.488', '1'],
    ['0.576', '0.11', '-0.799', '0.305', '0.732', '0.549', '1'],
    ['0.553', '0.11', '-0.819', '1.221', '-0.732', '-0.916', '1'],
    ['0.575', '0.117', '-0.809', '0.916', '0.854', '0.488', '1'],
    ['0.565', '0.112', '-0.814', '0.549', '0.488', '0.793', '1'],
    ['-0.007', '-0.051', '0.982', '0.61', '0.61', '0.122', '0'],
    ['-0.007', '-0.053', '0.981', '0.732', '0.732', '0.366', '0'],
    ['-0.006', '-0.053', '0.982', '0.61', '0.488', '0.183', '0'],
    ['-0.005', '-0.052', '0.984', '0.61', '0.61', '0.366', '0'],
    ['-0.006', '-0.052', '0.983', '0.793', '0.488', '0.183', '0'],
    ['-0.006', '-0.053', '0.982', '0.732', '0.427', '0.305', '0'],
    ['-0.007', '-0.051', '0.983', '0.671', '0.61', '0.366', '0'],
    ['-0.006', '-0.052', '0.983', '0.793', '0.793', '0.305', '0'],
    ['-0.006', '-0.052', '0.982', '0.793', '0.488', '0.366', '0'],
    ['-0.006', '-0.051', '0.982', '0.732', '0.671', '0.305', '0']
  ];

  final List<String> header = ["ax", "ay", "az", "gx", "gy", "gz", "class"];
  List<List<String>> onData = [];
  List<List<String>> offData = [];

  void setConnected(fromContext, bool value) {
    Provider.of<ConnectionProvider>(fromContext, listen: false).setConnected = value;
  }

  bool connectionValue(fromContext) {
    return Provider.of<ConnectionProvider>(fromContext, listen: false).isConnected;
  }

  // StreamSubscription? subscription;
  StreamSubscription? subscription;
  StreamSubscription? deviceState;
  StreamSubscription? readStream;
  StreamSubscription? updateStream;
  StreamSubscription? callbackControllerStream;

  @override
  void initState() {
    super.initState();
    ble = widget.ble;
    count = 49;
    chartAccData = <_ChartData>[];
    chartGyroData = <_ChartData>[];
    listenCallback();
  }

  void listenCallback() {
    callbackControllerStream = ble!.callbackController.stream.asBroadcastStream().listen((List value) {
      // value = [String callbackMessage, double sendingProgress ,int statusCode]
      msg(value.first, value.last);
      Provider.of<CallbackProvider>(context, listen: false).inform(value.first, value.last);
    });
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

  /* ------------------------------------------------- */
  // EVENT LISTENERS
  void _readData(BluetoothCharacteristic? characteristic) {
    readStream = characteristic!.onValueReceived.listen((value) {
      List<int> readData = List.from(value);
      String parsedData = String.fromCharCodes(readData);

      if (readData.isNotEmpty && readData != []) {
        if (characteristic.uuid.toString() == ble!.ACC_DATA_UUID) {
          accData = parsedData;
        } else if (characteristic.uuid.toString() == ble!.GYRO_DATA_UUID) {
          gyroData = parsedData;
        } else if (characteristic.uuid.toString() == ble!.DIST_TEMP_DATA_UUID) {
          setState(() {
            List<double> parsedDistTemp = dataParse(parsedData);
            distance = parsedDistTemp[0].toInt();
            temperature = parsedDistTemp[1];
          });
        }
      }
    });
  }

  void _readUpdateData(BluetoothCharacteristic? characteristic) {
    updateStream = characteristic!.onValueReceived.listen((value) {
      List<int> readData = List.from(value);
      String parsedData = String.fromCharCodes(readData);
      if (readData.isNotEmpty && readData != []) {
        ble!.dashboardData += parsedData;
      }
    });
  }

  /// Returns the realtime Cartesian line chart.
  SizedBox _buildLiveAccChart(context, {double height = 130, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Accelerometer',
            textStyle: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.inverseSurface.withAlpha(125),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          plotAreaBorderWidth: 0,
          primaryXAxis: NumericAxis(
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            minimum: -2,
            maximum: 2,
            isVisible: false,
          ),
          series: <SplineSeries<_ChartData, int>>[
            SplineSeries<_ChartData, int>(
              name: 'x',
              onRendererCreated: (ChartSeriesController controller) {
                axAxisController = controller;
              },
              dataSource: chartAccData!,
              color: connectionValue(context) ? CustomColor.lineXColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.x,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'y',
              onRendererCreated: (ChartSeriesController controller) {
                ayAxisController = controller;
              },
              dataSource: chartAccData!,
              color: connectionValue(context) ? CustomColor.lineYColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.y,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'z',
              onRendererCreated: (ChartSeriesController controller) {
                azAxisController = controller;
              },
              dataSource: chartAccData!,
              color: connectionValue(context) ? CustomColor.lineZColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.z,
              animationDuration: 0,
            )
          ],
        ),
      ),
    );
  }

  SizedBox _buildLiveGyroChart(context, {double height = 130, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Gyroscope',
            textStyle: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.inverseSurface.withAlpha(125),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          plotAreaBorderWidth: 0,
          primaryXAxis: NumericAxis(
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            minimum: -500,
            maximum: 500,
            isVisible: false,
          ),
          series: <SplineSeries<_ChartData, int>>[
            SplineSeries<_ChartData, int>(
              name: 'x',
              onRendererCreated: (ChartSeriesController controller) {
                gxAxisController = controller;
              },
              dataSource: chartGyroData!,
              color: connectionValue(context) ? CustomColor.lineXColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.x,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'y',
              onRendererCreated: (ChartSeriesController controller) {
                gyAxisController = controller;
              },
              dataSource: chartGyroData!,
              color: connectionValue(context) ? CustomColor.lineYColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.y,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'z',
              onRendererCreated: (ChartSeriesController controller) {
                gzAxisController = controller;
              },
              dataSource: chartGyroData!,
              color: connectionValue(context) ? CustomColor.lineZColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.z,
              animationDuration: 0,
            )
          ],
        ),
      ),
    );
  }

  void handshake() async {
    print("calling this if function");
    // await Future.delayed(const Duration(milliseconds: 5000));
    if (ble != null && ble!.isConnected && !ble!.isFileTransferInProgress) {
      print("RECEIVING VALUES..................................");

      // String username = user['username'];
      // print("RECEIVING VALUES..................................$username");

      // var fileContents = utf8.encode('xupdaterequestx-$username-last-') as Uint8List;
      var fileContents = utf8.encode('xupdaterequestx-ryan-last-') as Uint8List;
      print("fileContents length is ${fileContents.length}");
      ble?.transferFile(fileContents);
    } else {
      print("isFileTransferInProgress: ${ble!.isFileTransferInProgress}");
    }
  }

  void _connectFromDevice() {
    ble!.connect();

    subscription = ble!.discoverController.stream.asBroadcastStream().listen(null);
    subscription!.onData((value) {
      if (value) {
        _readData(ble!.accDataCharacteristic);
        _readData(ble!.gyroDataCharacteristic);
        _readData(ble!.distTempDataCharacteristic);
        _readUpdateData(ble!.fileUpdateCharacteristic);
        timer = Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);

        // Listen from sudden disconnection
        deviceState = ble!.device!.connectionState.listen((state) async {
          if (state == BluetoothConnectionState.disconnected) {
            _disconnectFromDevice();
          }
        });

        final mtuSubscription = ble!.device!.mtu.listen((int mtu) {
          // iOS: initial value is always 23, but iOS will quickly negotiate a higher value
          // android: you must request higher mtu yourself
          Provider.of<ConnectionProvider>(context, listen: false).setMTU(mtu);
        });

        setState(() {
          setConnected(context, true);
        });
      }
    });

    // subscription!.cancel();
  }

  void _disconnectFromDevice() {
    ble!.disconnect();
    deviceState!.cancel();
    timer!.cancel();
    setState(() {
      setConnected(context, false);
      subscription!.cancel();
      deviceState!.cancel();
      readStream!.cancel();
      updateStream!.cancel();
      callbackControllerStream!.cancel();
      timer!.cancel();

      subscription = null;
      deviceState = null;
      readStream = null;
      updateStream = null;
      callbackControllerStream = null;
      timer = null;
    });
  }

  void updateControllerDataSource(listData, controller, isEdge) {
    if (isEdge) {
      controller?.updateDataSource(
        addedDataIndexes: <int>[listData!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      controller?.updateDataSource(
        addedDataIndexes: <int>[listData!.length - 1],
      );
    }
  }

  // Continously updating the data source based on timer
  void _updateDataSource(Timer timer) {
    List<double> acc = dataParse(accData!);
    List<double> gyro = dataParse(gyroData!);
    chartAccData!.add(_ChartData(count, acc[0], acc[1], acc[2]));
    chartGyroData!.add(_ChartData(count, gyro[0], gyro[1], gyro[2]));

    if (chartAccData!.length == 50) {
      chartAccData!.removeAt(0);
      updateControllerDataSource(chartAccData, axAxisController, true);
      updateControllerDataSource(chartAccData, ayAxisController, true);
      updateControllerDataSource(chartAccData, azAxisController, true);
    } else {
      updateControllerDataSource(chartAccData, axAxisController, false);
      updateControllerDataSource(chartAccData, ayAxisController, false);
      updateControllerDataSource(chartAccData, azAxisController, false);
    }

    if (chartGyroData!.length == 50) {
      chartGyroData!.removeAt(0);
      updateControllerDataSource(chartGyroData, gxAxisController, true);
      updateControllerDataSource(chartGyroData, gyAxisController, true);
      updateControllerDataSource(chartGyroData, gzAxisController, true);
    } else {
      updateControllerDataSource(chartGyroData, gxAxisController, false);
      updateControllerDataSource(chartGyroData, gyAxisController, false);
      updateControllerDataSource(chartGyroData, gzAxisController, false);
    }

    count = count + 1;
  }

  bool isCapturing = false;
  void _captureData(BuildContext context, int sender) {
    //
    setState(() {
      isCapturing = true;
    });
    //
    int n = 300; // 300/200ms per data = takes 60 seconds
    onCaptureTimer = Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
      List<double> acc = dataParse(accData!);
      List<double> gyro = dataParse(gyroData!);

      List<String> captured = [
        // Accelerometer
        acc[0].toString(),
        acc[1].toString(),
        acc[2].toString(),
        // Gyroscope
        gyro[0].toString(),
        gyro[1].toString(),
        gyro[2].toString(),
        // Label
        sender.toString(),
      ];

      if (sender == 1) {
        onData.add(captured);
      } else {
        offData.add(captured);
      }

      setState(() {
        if (sender == 1) {
          onTargetText = n.toString();
        } else {
          offTargetText = n.toString();
        }
      });

      if (n == 1) {
        timer.cancel();
        setState(() {
          isCapturing = false;
          if (sender == 1) {
            onTargetText = 'DONE';
          } else {
            offTargetText = 'DONE';
          }
        });
      }
      n -= 1;
    });
  }

  /* ------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDialOpen = ValueNotifier(false);
    bool isNotified = Provider.of<ConnectionProvider>(context, listen: true).isNotified;

    if (isNotified && !connectionValue(context)) {
      print('toggle true');
      _connectFromDevice();
      Provider.of<ConnectionProvider>(context, listen: false).toggle(false);

      // String x =
      //     "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383 384 385 386 387 388 389 390 391 392 393 394 395 396 397 398 399 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 419 420 421 422 423 424 425 426 427 428 429 430 431 432 433 434 435 436 437 438 439 440 441 442 443 444 445 446 447 448 449 450 451 452 453 454 455 456 457 458 459 460 461 462 463 464 465 466 467 468 469 470 471 472 473 474 475 476 477 478 479 480 481 482 483 484 485 486 487 488 489 490 491 492 493 494 495 496 497 498 499 500 501 502 503 504 505 506 507 508 509 510 511 512 513 514 515 516 517 518 519 520 521 522 523 524 525 526 527 528 529 530 531 532 533 534 535 536 537 538 539 540 541 542 543 544 545 546 547 548 549 550 551 552 553 554 555 556 557 558 559 560 561 562 563 564 565 566 567 568 569 570 571 572 573 574 575 576 577 578 579 580 581 582 583 584 585 586 587 588 589 590 591 592 593 594 595 596 597 598 599 600 601 602 603 604 605 606 607 608 609 610 611 612 613 614 615 616 617 618 619 620 621 622 623 624 625 626 627 628 629 630 631 632 633 634 635 636 637 638 639 640 641 642 643 644 645 646 647 648 649 650 651 652 653 654 655 656 657 658 659 660 661 662 663 664 665 666 667 668 669 670 671 672 673 674 675 676 677 678 679 680 681 682 683 684 685 686 687 688 689 690 691 692 693 694 695 696 697 698 699 700 701 702 703 704 705 706 707 708 709 710 711 712 713 714 715 716 717 718 719 720 721 722 723 724 725 726 727 728 729 730 731 732 733 734 735 736 737 738 739 740 741 742 743 744 745 746 747 748 749 750 751 752 753 754 755 756 757 758 759 760 761 762 763 764 765 766 767 768 769 770 771 772 773 774 775 776 777 778 779 780 781 782 783 784 785 786 787 788 789 790 791 792 793 794 795 796 797 798 799 800 801 802 803 804 805 806 807 808 809 810 811 812 813 814 815 816 817 818 819 820 821 822 823 824 825 826 827 828 829 830 831 832 833 834 835 836 837 838 839 840 841 842 843 844 845 846 847 848 849 850 851 852 853 854 855 856 857 858 859 860 861 862 863 864 865 866 867 868 869 870 871 872 873 874 875 876 877 878 879 880 881 882 883 884 885 886 887 888 889 890 891 892 893 894 895 896 897 898 899 900 901 902 903 904 905 906 907 908 909 910 911 912 913 914 915 916 917 918 919 920 921 922 923 924 925 926 927 928 929 930 931 932 933 934 935 936 937 938 939 940 941 942 943 944 945 946 947 948 949 950 951 952 953 954 955 956 957 958 959 960 961 962 963 964 965 966 967 968 969 970 971 972 973 974 975 976 977 978 979 980 981 982 983 984 985 986 987 988 989 990 991 992 993 994 995 996 997 998 999 1000 1001 1002 1003 1004 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 1036 1037 1038 1039 1040 1041 1042 1043 1044 1045 1046 1047 1048 1049 1050 1051 1052 1053 1054 1055 1056 1057 1058 1059 1060 1061 1062 1063 1064 1065 1066 1067 1068 1069 1070 1071 1072 1073 1074 1075 1076 1077 1078 1079 1080 1081 1082 1083 1084 1085 1086 1087 1088 1089 1090 1091 1092 1093 1094 1095 1096 1097 1098 1099 1100 1101 1102 1103 1104 1105 1106 1107 1108 1109 1110 1111 1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1124 1125 1126 1127 1128 1129 1130 1131 1132 1133 1134 1135 1136 1137 1138 1139 1140 1141 1142 1143 1144 1145 1146 1147 1148 1149 1150 1151 1152 1153 1154 1155 1156 1157 1158 1159 1160 1161 1162 1163 1164 1165 1166 1167 1168 1169 1170 1171 1172 1173 1174 1175 1176 1177 1178 1179 1180 1181 1182 1183 1184 1185 1186 1187 1188 1189 1190 1191 1192 1193 1194 1195 1196 1197 1198 1199 1200 1201 1202 1203 1204 1205 1206 1207 1208 1209 1210 1211 1212 1213 1214 1215 1216 1217 1218 1219 1220 1221 1222 1223 1224 1225 1226 1227 1228 1229 1230 1231 1232 1233 1234 1235 1236 1237 1238 1239 1240 1241 1242 1243 1244 1245 1246 1247 1248 1249 1250 1251 1252 1253 1254 1255 1256 1257 1258 1259 1260 1261 1262 1263 1264 1265 1266 1267 1268 1269 1270 1271 1272 1273 1274 1275 1276 1277 1278 1279 1280 1281 1282 1283 1284 1285 1286 1287 1288 1289 1290 1291 1292 1293 1294 1295 1296 1297 1298 1299 1300 1301 1302 1303 1304 1305 1306 1307 1308 1309 1310 1311 1312 1313 1314 1315 1316 1317 1318 1319 1320 1321 1322 1323 1324 1325 1326 1327 1328 1329 1330 1331 1332 1333 1334 1335 1336 1337 1338 1339 1340 1341 1342 1343 1344 1345 1346 1347 1348 1349 1350 1351 1352 1353 1354 1355 1356 1357 1358 1359 1360 1361 1362 1363 1364 1365 1366 1367 1368 1369 1370 1371 1372 1373 1374 1375 1376 1377 1378 1379 1380 1381 1382 1383 1384 1385 1386 1387 1388 1389 1390 1391 1392 1393 1394 1395 1396 1397 1398 1399 1400 1401 1402 1403 1404 1405 1406 1407 1408 1409 1410 1411 1412 1413 1414 1415 1416 1417 1418 1419 1420 1421 1422 1423 1424 1425 1426 1427 1428 1429 1430 1431 1432 1433 1434 1435 1436 1437 1438 1439 1440 1441 1442 1443 1444 1445 1446 1447 1448 1449 1450 1451 1452 1453 1454 1455 1456 1457 1458 1459 1460 1461 1462 1463 1464 1465 1466 1467 1468 1469 1470 1471 1472 1473 1474 1475 1476 1477 1478 1479 1480 1481 1482 1483 1484 1485 1486 1487 1488 1489 1490 1491 1492 1493 1494 1495 1496 1497 1498 1499 1500 1501 1502 1503 1504 1505 1506 1507 1508 1509 1510 1511 1512 1513 1514 1515 1516 1517 1518 1519 1520 1521 1522 1523 1524 1525 1526 1527 1528 1529 1530 1531 1532 1533 1534 1535 1536 1537 1538 1539 1540 1541 1542 1543 1544 1545 1546 1547 1548 1549 1550 1551 1552 1553 1554 1555 1556 1557 1558 1559 1560 1561 1562 1563 1564 1565 1566 1567 1568 1569 1570 1571 1572 1573 1574 1575 1576 1577 1578 1579 1580 1581 1582 1583 1584 1585 1586 1587 1588 1589 1590 1591 1592 1593 1594 1595 1596 1597 1598 1599 1600 1601 1602 1603 1604 1605 1606 1607 1608 1609 1610 1611 1612 1613 1614 1615 1616 1617 1618 1619 1620 1621 1622 1623 1624 1625 1626 1627 1628 1629 1630 1631 1632 1633 1634 1635 1636 1637 1638 1639 1640 1641 1642 1643 1644 1645 1646 1647 1648 1649 1650 1651 1652 1653 1654 1655 1656 1657 1658 1659 1660 1661 1662 1663 1664 1665 1666 1667 1668 1669 1670 1671 1672 1673 1674 1675 1676 1677 1678 1679 1680 1681 1682 1683 1684 1685 1686 1687 1688 1689 1690 1691 1692 1693 1694 1695 1696 1697 1698 1699 1700 1701 1702 1703 1704 1705 1706 1707 1708 1709 1710 1711 1712 1713 1714 1715 1716 1717 1718 1719 1720 1721 1722 1723 1724 1725 1726 1727 1728 1729 1730 1731 1732 1733 1734 1735 1736 1737 1738 1739 1740 1741 1742 1743 1744 1745 1746 1747 1748 1749 1750 1751 1752 1753 1754 1755 1756 1757 1758 1759 1760 1761 1762 1763 1764 1765 1766 1767 1768 1769 1770 1771 1772 1773 1774 1775 1776 1777 1778 1779 1780 1781 1782 1783 1784 1785 1786 1787 1788 1789 1790 1791 1792 1793 1794 1795 1796 1797 1798 1799 1800 1801 1802 1803 1804 1805 1806 1807 1808 1809 1810 1811 1812 1813 1814 1815 1816 1817 1818 1819 1820 1821 1822 1823 1824 1825 1826 1827 1828 1829 1830 1831 1832 1833 1834 1835 1836 1837 1838 1839 1840 1841 1842 1843 1844 1845 1846 1847 1848 1849 1850 1851 1852 1853 1854 1855 1856 1857 1858 1859 1860 1861 1862 1863 1864 1865 1866 1867 1868 1869 1870 1871 1872 1873 1874 1875 1876 1877 1878 1879 1880 1881 1882 1883 1884 1885 1886 1887 1888 1889 1890 1891 1892 1893 1894 1895 1896 1897 1898 1899 1900 1901 1902 1903 1904 1905 1906 1907 1908 1909 1910 1911 1912 1913 1914 1915 1916 1917 1918 1919 1920 1921 1922 1923 1924 1925 1926 1927 1928 1929 1930 1931 1932 1933 1934 1935 1936 1937 1938 1939 1940 1941 1942 1943 1944 1945 1946 1947 1948 1949 1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000";
      // var fileContents = utf8.encode(x) as Uint8List;
      // _sendFileBlock(fileContents);
    }

    if (isNotified && connectionValue(context)) {
      print('toggle false ######################################');
      Provider.of<ConnectionProvider>(context, listen: false).toggle(false);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const ChartHeader(title: 'IMU Sensor'),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLiveAccChart(context),
                  const SizedBox(height: 10.0),
                  _buildLiveGyroChart(context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const ChartHeader(title: 'Externals'),

          // Externals
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Temperature
                ExternalSensorWidget(
                  icon: Icons.thermostat,
                  title: 'Temperature',
                  // valueDisplay: '$temperature°C',
                  valueDisplay: '$temperature°C',
                ),
                const SizedBox(width: 10),
                // Distance
                ExternalSensorWidget(
                  icon: Icons.linear_scale_rounded,
                  title: 'Distance',
                  // valueDisplay: '3.45cm',
                  valueDisplay: '${distance}cm',
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 0,
                  ),
                  child: DataButton(
                    // Add
                    onAddOnTarget: (!isCapturing && onData.isEmpty)
                        ? () {
                            if (connectionValue(context)) _captureData(context, 1);
                          }
                        : () {},
                    onAddOffTarget: (!isCapturing && offData.isEmpty)
                        ? () {
                            if (connectionValue(context)) _captureData(context, 0);
                          }
                        : () {},

                    // Delete
                    onDeleteOnTarget: () {
                      setState(() {
                        onTargetText = null;
                        onData.clear();
                      });
                    },
                    onDeleteOffTarget: () {
                      setState(() {
                        offTargetText = null;
                        offData.clear();
                      });
                    },

                    // Label
                    onTargetText: onTargetText,
                    offTargetText: offTargetText,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onPressed: !isBuildingModel && !isCapturing
                    ? () {
                        print('building...');
                        print(onData.length);
                        print(offData.length);
                        openBuildForm();

                        final snackBar = SnackBar(
                          content: const Text('Build success, ready to send!'),
                          action: SnackBarAction(
                            label: 'Okay',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );

                        // Find the ScaffoldMessenger in the widget tree
                        // and use it to show a SnackBar.
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    : () {
                        print('please wait');
                      },
                child: const Text('BUILD'),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: textInfo(info, infoCode),
            ),
          )
        ],
      ),
    );
  }

  startSpinningBar() {
    int i = 0;
    List<String> m = ['|', '/', '-', '\\'];
    loadingTextTimer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (i == m.length) i = 0;
      msg("Building model...       ${m[i]}");
      i += 1;
    });
  }

  Future<Widget> buildPageAsync([ble]) async {
    return Future.microtask(() {
      return ResultsPage(ble: ble);
    });
  }

  void viewResults([ble]) async {
    var page = await buildPageAsync(ble);
    var route = MaterialPageRoute(builder: (_) => page);
    if (!mounted) return;
    Navigator.push(context, route);
  }

  Future openBuildForm() {
    final formKey = GlobalKey<FormState>();
    _textController.value = TextEditingValue.empty;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Build'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _textController.text != '' ? null : 'Cannot be empty',
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Enter model name'),
                    controller: _textController,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isBuildingModel = true;
                    });

                    Navigator.of(context).pop();
                    startSpinningBar();

                    String fileName = _textController.text;
                    var token = await UserSecureStorage.getToken();

                    String dir = await AppStorage.getDir();
                    String fileInputPath = "$dir/$fileName/${fileName}_input.csv";
                    String fileModelPath = "$dir/$fileName/${fileName}_model.h";
                    String fileCallbackPath = "$dir/$fileName/${fileName}_callback.csv";
                    String fileInfoPath = "$dir/$fileName/${fileName}_info.json";

                    await AppStorage.writeCsv(
                      data: [header, ...onData, ...offData],
                      filePath: fileInputPath,
                    );

                    buildClass.sendInput(
                      filePath: fileInputPath,
                      modelName: _textController.text,
                      userToken: token,
                    );

                    Future<TrainedModels> model = buildClass.model;
                    model.then((value) async {
                      int errorsCount = 0;
                      var response = value.toJson();

                      // save response as json
                      await AppStorage.writeJson(data: response, filePath: fileInfoPath);

                      msg('Downloading your model, please wait.');
                      // MODEL
                      await buildClass
                          .downloadFile(fileUrl: response['file'], location: fileModelPath)
                          .then((value) {
                        msg(value);
                      }).onError((error, _) {
                        errorsCount += 1;
                      });

                      // CALLBACK
                      await buildClass
                          .downloadFile(fileUrl: response['callback_file'], location: fileCallbackPath)
                          .then((value) {
                        msg(value);
                      }).onError((error, _) {
                        errorsCount += 1;
                      });

                      if (errorsCount == 0) {
                        msg('Build success, ready to send!', 2);
                      } else {
                        msg('Error building the model', -1);
                      }
                    }).onError((error, _) {
                      msg(error.toString(), -1);
                    }).whenComplete(() {
                      setState(() {
                        isBuildingModel = false;
                      });
                      loadingTextTimer!.cancel();
                    });
                  }
                },
                child: const Text('Submit'),
              )
            ],
          );
        });
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
