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
