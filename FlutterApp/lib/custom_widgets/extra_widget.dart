import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExternalSensorWidget extends StatelessWidget {
  const ExternalSensorWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.valueDisplay,
  });
  final IconData icon;
  final String title;
  final String valueDisplay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(icon, size: 40),
                        ),
                      ],
                    ),
                  ),
                  // Texts
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.inverseSurface.withAlpha(128),
                          ),
                        ),
                        Text(
                          valueDisplay,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartHeader extends StatelessWidget {
  const ChartHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: GoogleFonts.bebasNeue(fontSize: 25),
      ),
    );
  }
}
