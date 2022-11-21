import 'package:flutter/material.dart';

class DataButton extends StatelessWidget {
  const DataButton({
    super.key,
    required this.onAddOnTarget,
    required this.onAddOffTarget,
    required this.onDeleteOnTarget,
    required this.onDeleteOffTarget,
  });
  final void Function() onAddOnTarget;
  final void Function() onDeleteOnTarget;
  final void Function() onAddOffTarget;
  final void Function() onDeleteOffTarget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )),
                          onPressed: onAddOnTarget,
                          child: const Text('ADD ON TARGET'),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            onPressed: onDeleteOnTarget,
                            child: Wrap(
                              children: const [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )),
                          onPressed: onAddOffTarget,
                          child: const Text('ADD OFF TARGET'),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            onPressed: onDeleteOffTarget,
                            child: Wrap(
                              children: const [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
