import 'package:flutter/material.dart';

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  const MyTooltip({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}

class BackgroundDesignL extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 80);
    path.quadraticBezierTo(size.width / 4, 30, size.width / 2, 45);
    path.quadraticBezierTo(3 / 4 * size.width, 60, size.width, 15);
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BackgroundDesignR extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, 80);
    path.quadraticBezierTo(3 / 4 * size.width, 30, size.width / 2, 45);
    path.quadraticBezierTo(size.width / 4, 60, 0, 15);
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
